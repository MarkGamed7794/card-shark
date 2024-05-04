--[[
    Card Blast

    A 5x5 grid of cards will appear. Type the reverse sides of 20 of the cards as fast as possible.
]]

local Flashcard = require "components.flashcard"
local SceneStack = require "scene_stack"
local FlashcardButton = require "components.flashcard_button"
local Scene = require "components.scene"
local Transform = require "components.transform2d"
local vec2 = require "components.vec2"
local Events = require "event"
local Fonts = require "fonts"

local CardBlastScene = Scene:extend()

CardBlastScene.name = "Card Blast"
CardBlastScene.description = "How fast can you answer?"
CardBlastScene.explanation = [[
A set of 25 cards will appear on screen.

Type the definitions of all 25 cards as fast as you can without making any mistakes!

Score is based off of how fast you are and how many mistakes you make.
]]

function CardBlastScene:new(card_set, mode)
    self.card_set = card_set.cards
    self.card_set_name = card_set.name
    self.mode_num = mode
    if(mode == 0) then self.mode = "front" end
    if(mode == 1) then self.mode = "back"  end
    if(mode == 2) then self.mode = "mixed" end
end

function CardBlastScene:init()
    local SCREEN_SIZE = vec2(love.graphics.getWidth(), love.graphics.getHeight())
    local cards = {}

    local remaining_cards = {}
    for k, _ in pairs(self.card_set) do
        table.insert(remaining_cards, k)
    end
   
    for i=0, 24 do
        local x, y = i % 5 - 2, math.floor(i / 5) - 2
        local a, b = math.random(1, 10), math.random(1, 10)

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
        Events:newEvent(1 + 0.05 * i,
            function()
                new_card.transform:ease_to(Transform{
                    position = vec2(x, y) * vec2(150, 80) + SCREEN_SIZE / 2 - vec2(0, 50),
                    angle = math.random(-100, 100) / math.pi / 200,
                    size = vec2(150, 70),
                    scale = vec2(0.8, 0.8)
                }, 1, function(x) return 1 - (1 - x) ^ 2 end)
            end
        )

        table.insert(cards, new_card)
    end

    self.cards = cards

    self.typed_answer = ""
    self.text_pos = vec2(love.graphics.getWidth() * 0.5, love.graphics.getHeight() - 60)

    self.time = -5
    self.strikes = 0
    self.cards_remaining = 25

    self.ended = false

    self.ending_cards = {}
end

function CardBlastScene:update(dt)
    for _, card in pairs(self.cards) do
        card:update(dt)
    end
    for _, card in pairs(self.ending_cards) do
        card:update(dt)
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

        if(score > get_high_score(self.card_set_name, "Card Blast", self.mode_num)) then
            set_high_score(self.card_set_name, "Card Blast", self.mode_num, score)

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

function CardBlastScene:draw()
    love.graphics.clear(0.8, 1, 0.9)
    for _, card in pairs(self.cards) do
        card:draw()
    end
    for _, card in pairs(self.ending_cards) do
        card:draw()
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

function CardBlastScene:keypressed(key, scan, rept)
    if(self.time < 0 or self.ended) then return end

    if(key == "space") then
        self.typed_answer = self.typed_answer .. " "
    elseif(key == "backspace") then
        self.typed_answer = string.sub(self.typed_answer, 1, #self.typed_answer-1)
    elseif(key == "return") then
        local give_strike = true

        for k, card in pairs(self.cards) do
            local is_valid = false
            if(card.answer == self.typed_answer) then
                is_valid = true
            end
            for _, back in pairs(card.alternate_answers) do
                if(back == self.typed_answer) then
                    is_valid = true
                end
            end
            if(is_valid and not card.eliminated) then
                give_strike = false
                self.cards_remaining = self.cards_remaining - 1
                card.eliminated = true
                card:flip(0.5)
                Events:newEvent(1, function()
                    local new_transform = card.transform:clone()
                    new_transform.position = vec2(new_transform.position.x, -100)
                    card.transform:ease_to(new_transform, 1, function(x) return x^2 end)
                end)
                Events:newEvent(2, function()
                    self.cards[k] = nil
                end)
            end
        end

        self.typed_answer = ""
        if(give_strike) then self.strikes = self.strikes + 1 end
    elseif(#key == 1) then
        self.typed_answer = self.typed_answer .. key
    end
end

function CardBlastScene:keyreleased(key, scan)
    
end

function CardBlastScene:mousepressed()
    if(self.ending_cards[3]) then
        self.ending_cards[3]:onClick()
    end
end

return CardBlastScene