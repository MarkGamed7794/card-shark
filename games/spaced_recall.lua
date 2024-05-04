--[[
    Card Blast

    A 5x5 grid of cards will appear. Type the reverse sides of 20 of the cards as fast as possible.
]]

local Flashcard = require "components.flashcard"
local FlashcardButton = require "components.flashcard_button"
local SceneStack = require "scene_stack"
local Scene = require "components.scene"
local Transform = require "components.transform2d"
local vec2 = require "components.vec2"
local Events = require "event"
local Fonts = require "fonts"

local SpacedRecallScene = Scene:extend()

SpacedRecallScene.name = "Spaced Recall"
SpacedRecallScene.description = "How far back can you remember?"
SpacedRecallScene.explanation = [[
25 cards will be shown to you, in order.

Type the definition on the back of the card you saw
*two cards ago* while remembering the answer to the current
card.

Your score is based off of how much time you take and how many
mistakes you make.
]]

function SpacedRecallScene:new(card_set, mode)
    self.card_set = card_set.cards
    self.card_set_name = card_set.name
    self.mode_num = mode
    if(mode == 0) then self.mode = "front" end
    if(mode == 1) then self.mode = "back"  end
    if(mode == 2) then self.mode = "mixed" end
end

local function hide_front(card)
    if(card.shown_side == "front") then
        card.front_text = "???"
    end
    if(card.shown_side == "back") then
        card.back_text = "???"
    end
    card:rerender()
end

function SpacedRecallScene:init()
    local SCREEN_SIZE = vec2(love.graphics.getWidth(), love.graphics.getHeight())
    local cards = {}

    local remaining_cards = {}
    for k, _ in pairs(self.card_set) do
        table.insert(remaining_cards, k)
    end
   
    for i=0, 24 do
        local picked_card = table.remove(remaining_cards, math.random(1, #remaining_cards))
        local picked_side = (self.mode == "front" and "front" or (self.mode == "back" and "back" or (math.random() < 0.5 and "front" or "back")))
        local new_card = Flashcard{
            front_text = self.card_set[picked_card].front,
            back_text = self.card_set[picked_card].back,
            shown_side = picked_side,
            transform = Transform{
                position = vec2(love.graphics.getWidth() / 2, -500),
                size = vec2(150, 70),
                scale = vec2(0.8, 0.8)
            },
        }
        new_card.alternate_answers = self.card_set[picked_card].alternate or {}
        new_card.answer = (picked_side == "front" and new_card.back_text or new_card.front_text)
        if(i >= 2) then
            Events:newEvent(1 + 0.05 * i,
                function()
                    new_card.transform:ease_to(Transform{
                        position = SCREEN_SIZE * vec2(0, 0.1 + 0.8 * i/25),
                        angle = math.random(-100, 100) / math.pi / 200,
                        size = vec2(150, 70),
                        scale = vec2(0.8, 0.8)
                    }, -1, function(x) return 1 - (1 - x) ^ 2 end)
                end
            )
        elseif(i == 1) then
            Events:newEvent(1 + 0.05 * i,
                function()
                    new_card.transform:ease_to(Transform{
                        position = SCREEN_SIZE * vec2(0.5, 0.2),
                        angle = math.random(-100, 100) / math.pi / 200,
                        size = vec2(150, 70),
                        scale = vec2(0.8, 0.8)
                    }, 1, function(x) return 1 - (1 - x) ^ 2 end)
                end
            )
        elseif(i == 0) then
            Events:newEvent(1 + 0.05 * i,
                function()
                    new_card.transform:ease_to(Transform{
                        position = SCREEN_SIZE * vec2(0.5, 0.6),
                        angle = math.random(-100, 100) / math.pi / 200,
                        size = vec2(150, 70),
                        scale = vec2(0.8, 0.8)
                    }, 1, function(x) return 1 - (1 - x) ^ 2 end)
                end
            )
        end

        table.insert(cards, new_card)
    end

    Events:newEvent(5, function()
        hide_front(cards[1])
    end)

    self.cards = cards
    self.extra_card = nil

    self.typed_answer = ""
    self.text_pos = vec2(love.graphics.getWidth() * 0.5, love.graphics.getHeight() - 60)

    self.time = -5
    self.strikes = 0
    self.cards_remaining = 25

    self.ended = false
    self.ending_cards = {}
end

function SpacedRecallScene:shiftCards()
    local SCREEN_SIZE = vec2(love.graphics.getWidth(), love.graphics.getHeight())
    local ease_func = function(x)
        if(x < 0.5) then return 0.5 * (x*2)^2 end
        return 1 - 0.5 * (2-x*2)^2
    end
    do
        if(self.cards[1]) then
            -- Card 2 goes to card 1's position
            local new_transform = self.cards[1].transform:clone()
            new_transform.position = SCREEN_SIZE * vec2(0.5, 0.6)
            self.cards[1].transform:ease_to(new_transform, 0.5, ease_func)
            hide_front(self.cards[1])
        end
    end
    do
        if(self.cards[2]) then
            -- Card 3 goes to card 2's position
            local new_transform = self.cards[2].transform:clone()
            new_transform.position = SCREEN_SIZE * vec2(0.5, 0.2)
            self.cards[2].transform:ease_to(new_transform, 0.5, ease_func)
        end
    end
    for i=3, #self.cards do
        local new_transform = self.cards[i].transform:clone()
        new_transform.position = SCREEN_SIZE * vec2(0, 0.1 + 0.8 * (i-3)/25)
        self.cards[i].transform:ease_to(new_transform, 0.5, ease_func)
    end
end

function SpacedRecallScene:update(dt)
    for _, card in pairs(self.cards) do
        card:update(dt)
    end
    for _, card in pairs(self.ending_cards) do
        card:update(dt)
    end
    if(self.extra_card) then
        self.extra_card:update(dt)
    end

    if(self.cards_remaining > 0) then
        self.time = self.time + dt
    elseif(not self.ended) then
        self.ended = true
        local title_card = Flashcard{
            front_text = "Congratulations!",
            back_text = "",
            shown_side = "front",
            transform = Transform{
                position = vec2(love.graphics.getWidth() / 2, -500),
                size = vec2(300, 70),
                scale = vec2(2, 2)
            },
        }
        table.insert(self.ending_cards, title_card)
        Events:newEvent(1,
            function()
                local SCREEN_SIZE = vec2(love.graphics.getWidth(), love.graphics.getHeight())
                title_card.transform:ease_to(Transform{
                    position = SCREEN_SIZE * vec2(0.5, 0.3),
                    angle = math.random(-100, 100) / math.pi / 400,
                    size = vec2(300, 70),
                    scale = vec2(2, 2)
                }, 1, function(x) return 1 - (1 - x) ^ 2 end)
            end
        )

        local score = math.floor(10000 / self.time * 1 / (1 + self.strikes * 0.2))
        local score_card = Flashcard{
            front_text = "Score: " .. score,
            back_text = "",
            shown_side = "front",
            transform = Transform{
                position = vec2(love.graphics.getWidth() / 2, -500),
                size = vec2(200, 50),
                scale = vec2(1, 1)
            },
        }
        table.insert(self.ending_cards, score_card)
        Events:newEvent(2,
            function()
                local SCREEN_SIZE = vec2(love.graphics.getWidth(), love.graphics.getHeight())
                score_card.transform:ease_to(Transform{
                    position = SCREEN_SIZE * vec2(0.5, 0.5),
                    angle = math.random(-100, 100) / math.pi / 400,
                    size = vec2(200, 50),
                    scale = vec2(1, 1)
                }, 1, function(x) return 1 - (1 - x) ^ 2 end)
            end
        )

        local back_button = FlashcardButton{
            text = "Return to Menu",
            transform = Transform{
                position = vec2(love.graphics.getWidth() / 2, -500),
                size = vec2(200, 50),
                scale = vec2(1, 1)
            },
            callback = function()
                SceneStack:pop_scene()
            end
        }
        table.insert(self.ending_cards, back_button)
        Events:newEvent(4,
            function()
                local SCREEN_SIZE = vec2(love.graphics.getWidth(), love.graphics.getHeight())
                back_button.transform:ease_to(Transform{
                    position = SCREEN_SIZE * vec2(0.5, 0.8),
                    angle = math.random(-100, 100) / math.pi / 400,
                    size = vec2(200, 50),
                    scale = vec2(1, 1)
                }, 1, function(x) return 1 - (1 - x) ^ 2 end)
            end
        )

        if(score > get_high_score(self.card_set_name, "Spaced Recall", self.mode_num)) then
            set_high_score(self.card_set_name, "Spaced Recall", self.mode_num, score)

            local high_score_card = Flashcard{
                front_text = "New high score!",
                back_text = "",
                shown_side = "front",
                transform = Transform{
                    position = vec2(love.graphics.getWidth() / 2, -500),
                    size = vec2(250, 50),
                    scale = vec2(1, 1)
                },
            }
            table.insert(self.ending_cards, high_score_card)
            Events:newEvent(3,
                function()
                    local SCREEN_SIZE = vec2(love.graphics.getWidth(), love.graphics.getHeight())
                    high_score_card.transform:ease_to(Transform{
                        position = SCREEN_SIZE * vec2(0.5, 0.6),
                        angle = math.random(-100, 100) / math.pi / 400,
                        size = vec2(250, 50),
                        scale = vec2(1, 1)
                    }, 1, function(x) return 1 - (1 - x) ^ 2 end)
                end
            )
        end
    end
end

function SpacedRecallScene:draw()
    love.graphics.clear(0.8, 1, 0.9)
    for _, card in pairs(self.cards) do
        card:draw()
    end
    for _, card in pairs(self.ending_cards) do
        card:draw()
    end
    if(self.extra_card) then
        self.extra_card:draw()
    end
    love.graphics.setColor(0, 0, 0, 1)

    love.graphics.setFont(Fonts[30])
    if(self.time >= 0 and not self.ended) then
        love.graphics.printf({{0,0,0}, self.typed_answer, {0,0,0,0.5}, "|"}, self.text_pos.x - 200, self.text_pos.y, 400, "center")
    end
    
    love.graphics.setFont(Fonts[18])
    love.graphics.printf(self.time < 0 and string.format("Ready? %d", math.ceil(-self.time)) or string.format("%.1f seconds", self.time), 20, 20, love.graphics.getWidth() - 40, "left")
    
    love.graphics.setColor(1,0,0)
    love.graphics.printf(string.rep("X", self.strikes, " "), 20, 20, love.graphics.getWidth() - 150, "right")
    love.graphics.setColor(0,0,0)
    love.graphics.printf(self.cards_remaining <= 0 and "Finished!" or string.format("%d to go", self.cards_remaining), 20, 20, love.graphics.getWidth() - 40, "right")
end

function SpacedRecallScene:keypressed(key, scan, rept)
    if(self.time < 0 or self.ended) then return end

    if(key == "space") then
        self.typed_answer = self.typed_answer .. " "
    elseif(key == "backspace") then
        self.typed_answer = string.sub(self.typed_answer, 1, #self.typed_answer-1)
    elseif(key == "return") then
        local give_strike = true

        local card = self.cards[1]

        local is_valid = false
        if(card.answer == self.typed_answer) then
            is_valid = true
        end
        for _, back in pairs(card.alternate_answers) do
            if(back == self.typed_answer) then
                is_valid = true
            end
        end
        if(true) then
            self.cards_remaining = self.cards_remaining - 1
            card.eliminated = true
            self.extra_card = table.remove(self.cards, 1)
            local new_transform = self.extra_card.transform:clone()
            new_transform.position = vec2(love.graphics.getWidth() + 200, new_transform.position.y)
            self.extra_card.transform:ease_to(new_transform, 0.5, function(x) return x^2 end)
            self:shiftCards()
        end

        self.typed_answer = ""
        if(not is_valid) then self.strikes = self.strikes + 1 end
    elseif(#key == 1) then
        self.typed_answer = self.typed_answer .. key
    end
end

function SpacedRecallScene:keyreleased(key, scan)
    
end

function SpacedRecallScene:mousepressed()
    if(self.ending_cards[3]) then
        self.ending_cards[3]:onClick()
    end
end

return SpacedRecallScene