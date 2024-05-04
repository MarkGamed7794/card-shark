local Flashcard = require "components.flashcard"

local FlashcardButton = Flashcard:extend()

function FlashcardButton:new(options)
    FlashcardButton.super.new(self, {
        shown_side = "front",
        transform = options.transform,
        front_text = options.text,
        back_text = ""
    })

    self.was_hovered = false
    self.is_hovered = false
    self.original_transform = self.transform:clone()
    self.callback = options.callback
end

function FlashcardButton:update(dt)
    FlashcardButton.super.update(self, dt)

    self.was_hovered = self.is_hovered
    local mx, my = love.mouse.getPosition()
    self.is_hovered =
        mx >= self.transform.position.x - self.transform.size.x * self.transform.scale.x * 0.5 and
        mx <= self.transform.position.x + self.transform.size.x * self.transform.scale.x * 0.5 and
        my >= self.transform.position.y - self.transform.size.y * self.transform.scale.y * 0.5 and
        my <= self.transform.position.y + self.transform.size.y * self.transform.scale.y * 0.5
        
    if(self.is_hovered and not self.was_hovered) then
        -- Button just became hovered
        self.original_transform = self.transform:clone()
        local new_transform = self.transform:clone()
        new_transform.scale = new_transform.scale * 1.1
        new_transform.angle = new_transform.angle - math.pi / 32

        self.transform:ease_to(new_transform, 0.1)
    end

    if(not self.is_hovered and self.was_hovered) then
        -- Button just became not hovered
        self.transform:ease_to(self.original_transform, 0.1)
    end
end

function FlashcardButton:onClick()
    if(self.is_hovered) then
        self.callback()
    end
end

return FlashcardButton