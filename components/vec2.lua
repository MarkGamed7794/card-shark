-- 2D vector type.

local Object = require "lib.classic"

---@class vec2: Object
---@operator add(vec2|number):vec2
---@operator sub(vec2|number):vec2
---@operator mul(vec2|number):vec2
---@operator div(vec2|number):vec2
---@overload fun(x: number, y: number): vec2
local vec2 = Object:extend()
vec2.__type = "vec2"

---Constructs and returns a new vec2.
---@param x number
---@param y number
function vec2:new(x, y)
    local new_x, new_y = x, y
    self.x = new_x
    self.y = new_y
end

---Clones a vec2.
function vec2:clone()
    return vec2(self.x, self.y)
end

---Rotates a vector by 90 degrees per rotation.
---@param rotations integer
---@return vec2
function vec2:rotate(rotations)
    local rotated = vec2(self.x, self.y)
    for i=1, rotations do
        rotated = vec2(rotated.y, rotated.x)
    end
    return rotated
end

---Adds one vec2 to another.
---@param other vec2
---@return vec2
function vec2:__add(other)
    return vec2(self.x + other.x, self.y + other.y)
end

---Subtracts one vec2 from another.
---@param other vec2
---@return vec2
function vec2:__sub(other)
    return vec2(self.x - other.x, self.y - other.y)
end

---Multiplies one vec2 by a number or another vec2 (dot product).
---@param other vec2
---@return vec2
---@overload fun(other: number): vec2
function vec2:__mul(other)
    if(type(self) == "number") then
        self, other = other, self
    end

    if(type(other) == "number") then
        return vec2(other * self.x, other * self.y)
    end
    
    -- dot product
    return vec2(self.x * other.x, self.y * other.y)
end

---Divides one vec2 by a number or another vec2 (inverse dot product).
---@param other any
---@return vec2
---@overload fun(other: number): vec2
function vec2:__div(other)
    if(type(other) == "number") then
        return vec2(self.x / other, self.y / other)
    end
    if(type(self) == "number") then
        return vec2(self / other.x, self / other.y)
    end

    -- dot product
    return vec2(self.x / other.x, self.y / other.y)
end

---Converts a vec2 to a string.
---@return string
function vec2:__tostring()
    return "(" .. self.x .. ", " .. self.y .. ")"
end

---Checks whether one vec2 is equal to another.
---@param other vec2
---@return boolean
function vec2:__eq(other)
    return self.x == other.x and self.y == other.y
end

function vec2:__concat(other)
    return tostring(self)..tostring(other)
end

vec2.ZERO      = vec2( 0,  0)
vec2.LEFT      = vec2(-1,  0)
vec2.RIGHT     = vec2( 1,  0)
vec2.UP        = vec2( 0, -1)
vec2.DOWN      = vec2( 0,  1)

return vec2