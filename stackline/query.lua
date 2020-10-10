local u = require 'stackline.lib.utils'
local log = hs.logger.new('stackline', 'info')

log.i("Loading module")

local Query = {}

local function pluckWindowIds(byStack)  -- {{{
    stackedWinIds = {}
    for _, group in pairs(byStack) do
        for _, win in pairs(group) do
            stackedWinIds[win.id] = true
        end
    end
    return stackedWinIds
end  -- }}}

local function groupByStack(ws)  -- {{{
    -- stackline windows -> groupedByStack
    local groupKey = stackline.config:get('features.fzyFrameDetect.enabled')
                        and 'stackIdFzy'
                        or 'stackId'
    return u.filter(
        u.groupBy(ws, groupKey),
        u.greaterThan(1)
    )
end  -- }}}

function ungroupStacks(byStack, windows)  -- {{{
    if u.length(byStack) == 0 then return {} end
    local stackedWinIds = pluckWindowIds(byStack)
    return u.filter(windows, function(w)
        return stackedWinIds[w.id]   --true if win id is in stackedWinIds
    end)
end  -- }}}

function Query:getWinStackIdxs(onSuccess) -- {{{
    -- TODO:Consider coroutine (allows HS to do other work while waiting for yabai)
    --      https://github.com/koekeishiya/yabai/issues/502#issuecomment-633378939

    -- call out to yabai to get stack-indexes
    hs.task.new("/bin/sh", function(_code, stdout, _stderr)
        local ok, json = pcall(hs.json.decode, stdout)
        if ok then
            onSuccess(json)
        else -- try again
            hs.timer.doAfter(1, function() self:getWinStackIdxs() end)
        end
    end, {c.paths.getStackIdxs}):start()
end -- }}}

function Query:groupWindows(windows) -- {{{
    -- Given stackline window objects
    --    1. Create stackline window objects
    --    2. Group wins by `stackId` prop (aka top-left frame coords)
    --    3. If at least one such group, also group wins by app (to workaround hs bug unfocus event bug)

    log.d('windows input to query:groupWindows()', hs.inspect(windows))

    self.stacks = groupByStack(windows)
    local unstacked = ungroupStacks(self.stacks, windows)
    self.appWindows = u.groupBy(unstacked, 'app') -- app names are keys in group
    return self
end -- }}}

function Query:removeGroupedWin(win) -- {{{
    -- remove given window if it's present in self.stacks windows
    self.stacks = u.map(self.stacks, function(stack)
        return u.filter(stack, function(w)
            return w.id ~= win.id
        end)
    end)
end -- }}}

function assignStackIndex(winStackIdxs)  -- {{{
    return function(win)
        local stackIdx = winStackIdxs[tostring(win.id)]

        -- Remove windows with stackIdx == 0. Such windows overlap exactly with
        -- other (potentially stacked) windows, and so are grouped with them,
        -- but they are NOT stacked according to yabai.
        -- Windows that belong to a *real* stack have stackIdx > 0.
        if stackIdx == 0 then self:removeGroupedWin(win) end

        -- set the stack idx
        win.stackIdx = stackIdx
    end
end  -- }}}

function Query:mergeWinStackIdxs(winStackIdxs) -- {{{
    -- merge windowID <> stack-index mapping queried from yabai into window objs
    u.each(self.stacks, function(stack)
        u.each(stack, assignStackIndex(winStackIdxs))
    end)

end -- }}}

local function shouldRestack(new) -- {{{
    -- Analyze self.stacks to determine if a stack refresh is needed
    --  • change num stacks (+/-)
    --  • changes to existing stack
    --    • change position
    --    • change num windows (win added / removed)

    local curr = stackline.manager:getSummary()
    new = stackline.manager:getSummary(u.values(new))

    if curr.numStacks ~= new.numStacks then
        print('num stacks changed')
        return true
    elseif not u.equal(curr.topLeft, new.topLeft) then
        print('position changed')
        return true
    elseif not u.equal(curr.numWindows, new.numWindows) then
        print('num windows changed')
        return true
    end

    print('Should not redraw.')
end -- }}}

function Query:whenStackIdxDone(winStackIndexes)  -- {{{
    -- Add the stack indexes from yabai to the hs window data
    self:mergeWinStackIdxs(winStackIndexes)

    -- hand over to the Stack module
    stackline.manager:ingest(
        self.stacks,
        self.appWindows
    )
end  -- }}}

function Query:windowsCurrentSpace() -- {{{
    -- set self.stacks & self.appWindows
    self:groupWindows(stackline:getWindows())

    if shouldRestack(self.stacks) then
        -- set self.winStackIdxs (async shell call to yabai)
        self:getWinStackIdxs(function(r)
            Query:whenStackIdxDone(r)
        end)
    end
end -- }}}

return Query
