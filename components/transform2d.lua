local Object = require "lib.classic"
local vec2 = require "components.vec2"

---@class Transform2D
---@field ease {target:table<string,any>?, length: number, timer: number, easing: function}
local Transform2D = Object:extend()

function Transform2D:new(options)
    self.position = options.position or vec2.ZERO
    self.size = options.size or vec2(1, 1)
    self.angle = options.angle or 0
    self.scale = options.scale or vec2(1, 1)
    self.origin = options.origin or self.size / 2
    self.shear = options.shear or vec2.ZERO

    self.ease = {
        target = nil,
        timer = 0,
        length = 0,
        easing = function(x) return x end,
    }
    self.original = nil
end

function Transform2D:clone()
    return Transform2D(self)
end

function Transform2D:drawObject(drawable)
    love.graphics.draw(
        drawable,
        self.position.x,
        self.position.y,
        self.angle,
        self.scale.x,
        self.scale.y,
        self.origin.x,
        self.origin.y,
        self.shear.x,
        self.shear.y
    )
end

function Transform2D:ease_to(target, time, easing)
    self.ease.target = target:clone()
    self.ease.timer = 0
    self.ease.length = time
    self.ease.easing = easing or function(x) return x end

    self.original = {
        position = self.position:clone(),
        angle = self.angle,
        scale = self.scale:clone(),
        origin = self.origin:clone(),
        shear = self.shear:clone()
    }
    
end

local function lerp(a, b, x)
    return a * (1 - x) + b * x
end

function Transform2D:update(dt)
    if(self.ease.target) then
        self.ease.timer = self.ease.timer + dt

        if(self.ease.timer >= self.ease.length) then
            self.position = self.ease.target.position
            self.angle = self.ease.target.angle
            self.scale = self.ease.target.scale
            self.origin = self.ease.target.origin
            self.shear = self.ease.target.shear
            
            self.ease.target = nil
        else
            local t = self.ease.easing(self.ease.timer / self.ease.length)
            self.position = lerp(self.original.position, self.ease.target.position, t)
            self.angle = lerp(self.original.angle, self.ease.target.angle, t)
            self.scale = lerp(self.original.scale, self.ease.target.scale, t)
            self.origin = lerp(self.original.origin, self.ease.target.origin, t)
            self.shear = lerp(self.original.shear, self.ease.target.shear, t)
        end
    end
end

return Transform2D