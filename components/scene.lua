local Object = require "lib.classic"

---@class Scene: Object
local Scene = Object:extend()

function Scene:new(options)
    self.init = function() end
    self.update = function() end
    self.draw = function() end
    self.keypressed = function () end
    self.keyreleased = function () end
end

return Scene