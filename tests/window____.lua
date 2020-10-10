
  -- BUSTED doesn't work {{{
  -- require 'busted.runner'()

  -- describe("here goes with my tests", function()
  --   it("can now test my stuff", function()
  --     return true
  --   end)
  -- end)
  -- }}}

local test = require 'simple_test'
local _hs = require 'stackline.tests.mocks._hs'
local twoWin_oneStack = require 'stackline.tests.fixtures.twoWin_oneStack'

-- local stackline = require 'stackline.stackline.stackline'
local query = require 'stackline.stackline.query'
-- local window = require 'stackline.stackline.window'
-- local stack = require 'stackline.stackline.stack'

  -- Stackline window constructor:   --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --- {{{
  -- local ws = {
  --     title      = hsWin:title(),                -- window title
  --     app        = hsWin:application():name(),   -- app name (string)
  --     id         = hsWin:id(),                   -- window id (string) NOTE: HS win.id == yabai win.id
  --     frame      = hsWin:frame(),                -- x,y,w,h of window (table)
  --     stackId    = stackIdResult.stackId,        -- "{{x}|{y}|{w}|{h}" e.g., "35|63|1185|741" (string)
  --     topLeft    = stackIdResult.topLeft,        -- "{{x}|{y}" e.g., "35|63" (string)
  --     stackIdFzy = stackIdResult.fzyFrame,       -- "{{x}|{y}" e.g., "35|63" (string)
  --     _win       = hsWin,                        -- hs.window object (table)
  --     screen     = hsWin:screen():id(),
  --     indicator  = nil,                          -- the canvas element (table)
  -- }
  -- }}}

-- w:setupIndicator() {{{
  -- METHODS CALLED IN WINDOW:SETUPiNDICATOR()
  -- self.screen = self._win:screen()
  -- self.frame = self.screen:absoluteToLocal(..frame)
  -- isStackFocused()
  --    -> self.stack:anyFocused()
  --       -> w:isFocused()
  --
-- }}}

-- https://github.com/EvandroLG/simple_test {{{

-- assert.ok(test, [failure_message])
-- Checks if test is true.

-- assert.not_ok(test, [failure_message])
-- Checks if test is false.

-- assert.equal(actual, expected, [failure_message])
-- Tests if actual is equal expected.

-- assert.not_equal(actual, expected, [failure_message])
-- Checks if actual is not equal expected.

-- assert.throw(function, params, [raised_message], [failure_message])
-- Checks if a function throws an exception and optionally compare the throw error.

-- assert.delta(actual_float, expected_float, [delta], [failure_message])
-- Checks if actual_float and expected_float are equal within optional delta tolerance

-- assert.deep_equal(actual, expected, [failure_message])
-- Tests for deep equality between the actual and expected parameters.
-- }}}

local stackMock = {}
local results = {}


local function make_hs(ws)  
  return u.map(
    ws,
    function(w)
      return _hs.window:new(w)
    end
  )
end  

local function noNilVals(t)  
  for k,v in pairs(t) do
    return type(v) ~= nil
  end
end  

local function sort(t)  
  return table.sort(t, function(a,b) return a < b end)
end  

local rawWinData = twoWin_oneStack.windows
local hsWins = make_hs(rawWinData)
local sws = stackline:getWindows(hsWins)

-- TODO: move to be adjacent to rawWinData 
local expected = {  
  num_wins = 2,
  win_keys = { "stackIdFzy", "frame", "_win", "topLeft", "stackId", "title", "id", "app" },
}  


local function run()
  -- NOTE: add 'test()' to block words in debug.lua 
  -- to avoid always printing 'nil' when tests run
  test('2 stackline windows were created', function(a)
    a.equal(#sws, expected.num_wins)
  end)

  test('Stackline windows have the expected keys', function(a)
    local akeys = sort(u.keys(sws[1]))
    local eKeys = sort(expected.win_keys)
    a.deep_equal(aKeys, eKeys)
  end)


  test('Successfully group windows by stack & app', function(a)
    -- NOTE: test requires changing query:groupWindows() to return self
    --        …it returns nothing on master
    local grouped = query:groupWindows(sws)
    results.byApp = grouped.appWindows
    results.byStack = grouped.stacks
  end)

  -- NOTE: message args are flipped in a.equal. Fixed manually.
  -- /usr/local/Cellar/luarocks/3.4.0/share/lua/5.3/simple_test/assertions.lua:7
  test('1 stack was created', function(a)
    a.equal(u.length(results.byStack), 1)
  end)

  test('2 appWindows were grouped', function(a)
    a.equal(u.length(results.byApp), 2)
  end)
end

return run
