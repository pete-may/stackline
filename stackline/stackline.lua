require("hs.ipc")
u = require 'stackline.lib.utils'

-- Aliases / shortcuts
local wf    = hs.window.filter
local timer = hs.timer.delayed
local log   = hs.logger.new('stackline', 'info')
local click = hs.eventtap.event.types['leftMouseDown'] -- fyi, print hs.eventtap.event.types to see all event types


-- function i(method)
--    return load("function(x) return " .. method .. "(x) end")
-- end
-- ↑ maybe a way to simply call methods in callbacks without wrapping in a fn?
-- map(x, i('stackline.window:new'))

log.i("Loading module")

stackline = {}
stackline.config = require 'stackline.stackline.configManager'
stackline.window = require 'stackline.stackline.window'
-- stackline.query = require 'stackline.stackline.query' -- NOTE: breaks local vars at top of query.lua

stackline.wf = wf.new():setOverrideFilter{  -- {{{
    -- Default window filter controls what windows hs "sees"
    -- Required before initialization
    visible = true,   -- (i.e. not hidden and not minimized)
    fullscreen = false,
    currentSpace = true,
    allowRoles = 'AXStandardWindow',
}  -- }}}

stackline.updateOn = { -- {{{
    wf.windowCreated,      -- window added
    wf.windowUnhidden,
    wf.windowUnminimized,

    wf.windowFullscreened, -- window changed
    wf.windowUnfullscreened,
    wf.windowMoved,        -- NOTE: winMoved includes move AND resize evts

    wf.windowDestroyed,    -- window removed
    wf.windowHidden,
    wf.windowMinimized,
} -- }}}

stackline.redrawOn = {  -- {{{
    wf.windowFocused,
    wf.windowNotVisible,
    wf.windowUnfocused,
} -- }}}

function stackline:getWindows(ws) -- {{{
    -- TODO: ws arg is for testing only. Refactor to naturally take hs wins — e.g., makeWindows(ws)
    -- hs windows -> stackline window objects
    return u.map(
        ws or stackline.wf:getWindows(),
        function(w) return stackline.window:new(w) end
    )
end -- }}}

function stackline.redrawWinIndicator(hsWin) -- {{{
    -- NOTE: args hsWin, _app, _event
    -- Dedicated redraw method to *adjust* the existing canvas element is WAY
    -- faster than deleting the entire indicator & rebuilding it from scratch,
    -- particularly since this skips querying the app icon & building the icon image.
    local stackedWin = stackline.manager:findWindow(hsWin:id())
    if stackedWin then -- if non-existent, the focused win is not stacked
        stackedWin:redrawIndicator()
    end
end -- }}}

function stackline:init(userConfig) -- {{{
    log.i('starting stackline')

    -- init config with default conf + user overrides
    self.config:init( 
        table.merge(require 'stackline.conf', userConfig)
    )

    -- after initializing config, init stackmanager, and run update right away
    self.manager = require('stackline.stackline.stackmanager'):init()
    self.manager:update()

    -- Reuseable fn that runs at most once every 0.3s
    -- yabai is only queried if Hammerspoon query results are different than current state
    stackline.queryWindowState = timer.new(  
        self.config:get('advanced.maxRefreshRate'), 
        function() stackline.manager:update() end
    )   

    -- On each win evt above (or at most once every 0.3s)
    -- query window state and check if refersh needed
    self.wf:subscribe(
        self.updateOn, 
        function() self.queryWindowState:start() end
    )
    -- On each win evt listed, simply *redraw* indicators
    -- No need for heavyweight query + refresh
    self.wf:subscribe(
        self.redrawOn,
        self.redrawWinIndicator
     ) 

    -- Setup click tracker. Only used if user has enabled in config
    self.clickTracker = hs.eventtap.new({click}, function(e) 
        local clickAt = hs.geometry.point(e:location().x, e:location().y)
        local clickedWin = self.manager:getClickedWindow(clickAt)
        if clickedWin then
            clickedWin._win:focus()
            return true -- stops propogation
        end
    end)

    -- Activate clickToFocus if feature turned on
    if self.config:get('features.clickToFocus') then  
        log.i('FEAT: ClickTracker starting')
        self.clickTracker:start()
    end  

end -- }}}

function stackline:refreshClickTracker() -- {{{
    if self.clickTracker:isEnabled() then
        self.clickTracker:stop() -- always stop if running
    end

    local turnedOn = self.config:get('features.clickToFocus')

    if turnedOn then -- only start if feature is enabled
        log.d('features.clickToFocus is enabled!')
        self.clickTracker:start()
    end
end -- }}}

stackline.test = function()  -- {{{
    local toReload = { 
        "stackline.stackline.query",
        "stackline.stackline.stackmanager",
        "stackline.stackline.stack",
        "stackline.stackline.window",
        "stackline.stackline.stackline",
        "stackline.tests.window_spec",
    }

    for k,v in pairs(toReload) do
        package.loaded[v] = nil
    end
    -- collectgarbage()

    -- if not stackline.manager then
    --     stackline:init()
    -- end
    -- u.p(stackline.manager)

    -- local stackline = require 'stackline.stackline.stackline'
    local run = require 'stackline.tests.window_spec'

    local ok, res = pcall(run)
    if ok then
        if res ~= nil then
            u.p(res)
        end
    end
end  -- }}}

hs.spaces.watcher.new(function() -- {{{
    -- On space switch, query window state & refresh,
    -- plus refresh click tracker
    stackline.queryWindowState:start()
    stackline:refreshClickTracker()
end):start() -- }}}

return stackline


