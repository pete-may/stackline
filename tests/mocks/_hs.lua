local _hs = {}
_hs.window = {}

function _hs.window:new(x)        -- {{{
    -- local x = { id = nil, title = nil, app = nil, frame = nil, screen = {id = nil, frame = nil} }
    -- u.p(x)
  local win = {
    data = {
      id = x.id,
      title = x.title,
      app = x.app,
      frame = x.frame,
      isFocused = x.isFocused,
      screen = {id = x.screen.id, frame = x.screen.frame},
    },
  }
  setmetatable(win, self)
  self.__index = self
  return win
end  -- }}}

function _hs.window:frame()  -- {{{
  return hs.geometry.new(
    table.unpack(
      u.values(self.data.frame)
      )
    )
end  -- }}}

function _hs.window:id()  -- {{{
  return self.data.id
end  -- }}}

function _hs.window:title()  -- {{{
  return self.data.title
end  -- }}}

function _hs.window:application()  -- {{{
  return {
    name = function() return self.data.app end
  }
end  -- }}}

function _hs.window:isFocused()  -- {{{
  return self.data.isFocused
end  -- }}}

function _hs.window:screen()  -- {{{
  return {
    id = function()
      return self.data.screen.id
    end,
    frame = function()
      return self.data.screen.frame
    end,
  }
end  -- }}}

return _hs


