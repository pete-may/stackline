
--[[
Problem ------------------------------------------------------------------------
Icons are positioned relative to the window frame.
Some windows have size constraints (iterm), so stackline uses fuzzy frame detection
to identify windows in a stack.

When icons are positioned on the left side of the screen,
size-constraied window align on the left edge, so the left-side edges
of windows will be aligned even with size-constrained.

The *right* edges of windows are *not* aligned in size-constraied windows.
Example:

    Window 1
      frame = { -- hs.geometry.rect(805.0,48.0,921.0,1042.0)
        _h = 1042.0,
        _w = 921.0,  -- <<- WIDER
        _x = 805.0,
        _y = 48.0
      },

    Window 2
      frame = { -- hs.geometry.rect(805.0,48.0,916.0,1028.0)
        _h = 1028.0,
        _w = 916.0,
        _x = 805.0,
        _y = 48.0
      },


      icon_rect = {
        h = 24,
        w = 24,
        x = 1734.0, -- << ICON FURTHER TO THE RIGHT
        y = 54.0
      },
      icon_rect = {
        h = 24,
        w = 24,
        x = 1729.0,
        y = 92.4
      },

--]]



local config = {
  alpha = 1,
  color = {
    alpha = 1,
    white = 0.9
  },
  dimmer = 2.5,
  fadeDuration = 0.2,
  iconDimmer = 1.1,
  iconPadding = 4,
  offset = {
    x = 4,
    y = 2
  },
  padding = 4,
  pillThinness = 6,
  radius = 3,
  shouldFade = true,
  showIcons = true,
  size = 32,
  vertSpacing = 1.2
}


local output = {
  id = "780|30|900|1020",
  windows = { {
      _win = '<userdata 10>' -- hs.window: ~ — fish (0x6000037eb8b8),
      app = "kitty",
      config = '<table 2>',
      focus = true,
      frame = { -- hs.geometry.rect(805.0,48.0,921.0,1042.0)
        _h = 1042.0,
        _w = 921.0,
        _x = 805.0,
        _y = 48.0
      },
      iconIdx = 2,
      iconRadius = 10.666666666667,
      icon_rect = {
        h = 24,
        w = 24,
        x = 1734.0,
        y = 54.0
      },
      id = 444437,
      indicator = '<userdata 2>' -- hs.canvas: {{0, 0}, {1792, 1120}} (0x6000037c72b8),
      indicator_rect = {
        h = 32,
        w = 32,
        x = 1730.0,
        y = 50.0
      },
      otherAppWindows = { {
          app = "kitty",
          focus = false,
          id = 450887,
        } },
      rectIdx = 1,
      screen = '<userdata 9>' -- hs.screen: Color LCD (0x6000037f0038),
      screenFrame = { -- hs.geometry.rect(0.0,0.0,1792.0,1120.0)
        _h = 1120.0,
        _w = 1792.0,
        _x = 0.0,
        _y = 0.0
      },
      showIcons = true,
      side = "right",
      stack = '<table 1>',
      stackFocus = true,
      stackId = "805|48|921|1042",
      stackIdFzy = "780|30|900|1020",
      stackIdx = 1,
      title = "debug.lua (~/Programming/Projects/stackline/lib) ((1) of 11) - NVIM",
      topLeft = "805|48",
      width = 32
    }, {
      _win = '<userdata 10>' -- hs.window: ~ — fish (0x6000037eb8b8),
      app = "iTerm2",
      config = '<table 2>',
      focus = false,
      frame = { -- hs.geometry.rect(805.0,48.0,916.0,1028.0)
        _h = 1028.0,
        _w = 916.0,
        _x = 805.0,
        _y = 48.0
      },
      iconIdx = 2,
      iconRadius = 10.666666666667,
      icon_rect = {
        h = 24,
        w = 24,
        x = 1729.0,
        y = 92.4
      },
      id = 450902,
      indicator = '<userdata 11>' -- hs.canvas: {{0, 0}, {1792, 1120}} (0x6000037d96b8),
      indicator_rect = {
        h = 32,
        w = 32,
        x = 1725.0,
        y = 88.4
      },
      otherAppWindows = {},
      rectIdx = 1,
      screen = '<userdata 12>' -- hs.screen: Color LCD (0x6000037dc238),
      screenFrame = { -- hs.geometry.rect(0.0,0.0,1792.0,1120.0)
        _h = 1120.0,
        _w = 1792.0,
        _x = 0.0,
        _y = 0.0
      },
      showIcons = true,
      side = "right",
      stack = '<table 1>',
      stackFocus = true,
      stackId = "805|48|916|1028",
      stackIdFzy = "780|30|900|1020",
      stackIdx = 2,
      title = "~ — fish",
      topLeft = "805|48",
      width = 32
    } }
}
