local Object = require "lib.classic"
local vec2 = require "components.vec2"
local Transform2D = require "components.transform2d"
local fonts = require "fonts"
local Events = require "event"

---@class Flashcard: Object
---@field transform Transform2D
local Flashcard = Object:extend()

function Flashcard:new(options)
    self.shown_side = options.shown_side or "front"
    self.transform = options.transform or Transform2D{}
    self.front_text = options.front_text
    self.back_text = options.back_text
    self:rerender()
end

function Flashcard:rerender()
    self.front = love.graphics.newCanvas(self.transform.size.x, self.transform.size.y)
    self.back = love.graphics.newCanvas(self.transform.size.x, self.transform.size.y)

    local line_count = math.floor(self.transform.size.y / 10) - 1
    love.graphics.setFont(fonts[24])
    self.front:renderTo(function()
        love.graphics.clear({1, 1, 1, 1})

        love.graphics.setColor(0.8, 0.8, 1)
        for i=1, line_count do
            local y = self.transform.size.y / line_count * (0.5 + i)
            love.graphics.line(0, y, self.transform.size.x, y)
        end

        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(self.front_text, 0, self.transform.size.y / 2 - 12, self.transform.size.x, "center")
    end)
    self.back:renderTo(function()
        love.graphics.clear({1, 1, 1, 1})

        love.graphics.setColor(1, 0.8, 0.8)
        for i=1, line_count do
            local y = self.transform.size.y / line_count * (0.5 + i)
            love.graphics.line(0, y, self.transform.size.x, y)
        end

        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(self.back_text, 0, self.transform.size.y / 2 - 12, self.transform.size.x, "center")
    end)
end

function Flashcard:update(dt)
    self.transform:update(dt)
end

function Flashcard:draw()
    love.graphics.setColor(1, 1, 1, 1)
    self.transform:drawObject(self.shown_side == "front" and self.front or self.back)
    --if(self.transform.ease.target) then
    --    love.graphics.setColor(0, 0, 0, 1)
    --    love.graphics.print(string.format("%.2f/%.2f",self.transform.ease.timer,self.transform.ease.length), self.transform.position.x + 30, self.transform.position.y + 30)
    --    love.graphics.print(string.format("%s->%s",self.transform.original.position,self.transform.ease.target.position), self.transform.position.x + 30, self.transform.position.y + 50)
    --end
end

local function sine_ease(x)
    return (1 + math.sin(math.pi * (x - 0.5))) / 2
end

function Flashcard:flip(time)
    local new_transform = self.transform:clone()
    local original_transform = self.transform:clone()
    new_transform.scale = new_transform.scale * vec2(0, 1)
    self.transform:ease_to(new_transform, (time or 1) / 2, sine_ease)

    Events:newEvent((time or 1) / 2 or 1, function()
        self.shown_side = (self.shown_side == "front" and "back" or "front")
        self.transform:ease_to(original_transform, (time or 1) / 2, sine_ease)
    end)
end

return Flashcard