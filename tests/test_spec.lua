
package.path = ' /usr/local/share/lua/5.4/?/init.lua' .. package.path



--[[

All hammerspoon calls

hs.appfinder.appFromName
hs.canvas
hs.canvas.html
hs.canvas.new
hs.configdir
hs.console
hs.eventtap.event.types
hs.eventtap.new

hs.fnutils.concat
hs.fnutils.contains
hs.fnutils.copy
hs.fnutils.each
hs.fnutils.filter
hs.fnutils.map
hs.fnutils.partial
hs.fnutils.reduce
hs.fnutils.some

hs.geometry
hs.geometry.new
hs.geometry.point
hs.geometry.rect
hs.image.imageFromAppBundle
hs.ipc
hs.ipc.localPort
hs.json.decode
hs.logger.new
hs.notify.new
hs.screen
hs.spaces.watcher.new
hs.task.new
hs.timer.delayed
hs.timer.doAfter
hs.window
hs.window.filter
hs.window.focusedWindow
-- ]]



local i = require('inspect')
describe("here goes with my tests", function()
  it("can now test my stuff", function()
    for k,v in pairs(_G) do
      print(k, tostring(v))
    end
    print(i(_G))
    return true
  end)
end)
