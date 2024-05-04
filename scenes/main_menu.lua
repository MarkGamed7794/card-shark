local Flashcard = require "components.flashcard"
local Scene = require "components.scene"
local Transform = require "components.transform2d"
local vec2 = require "components.vec2"
local Events = require "event"
local Fonts = require "fonts"

local FlashcardButton = require "components.flashcard_button"
local SceneStack = require "scene_stack"

local MenuScene = Scene:extend()

function MenuScene:new()

end

function MenuScene:init()
    local SCREEN_SIZE = vec2(love.graphics.getWidth(), love.graphics.getHeight())
    self.free_play = {
        selected_cards = nil,
        selected_game = nil
    }
    self.challenge = {
        selected_cards = nil,
        selected_game = nil,
        mode = 0
    }
    
    local play_button =
        FlashcardButton{
            transform = Transform{
                position = SCREEN_SIZE * vec2(0.18, 0.9),
                size = vec2(200, 50),
            },
            text = "Play!",
            callback = function()
                SceneStack:push_scene(self.free_play.selected_game(self.free_play.selected_cards, self.mode))
            end
        }
        
    local play_button_2 =
        FlashcardButton{
            transform = Transform{
                position = SCREEN_SIZE * vec2(0.75, 0.95),
                size = vec2(200, 35),
            },
            text = "Play!",
            callback = function()
                SAVE_DATA.streak = 1
                SceneStack:push_scene(self.challenge.selected_game(self.challenge.selected_cards, self.challenge.mode))
            end
        }
    
    
    local mode_button = 
        FlashcardButton{
            transform = Transform{
                position = SCREEN_SIZE * vec2(0.4, 0.9),
                size = vec2(175, 50),
                scale = vec2(0.5, 0.5)
            },
            text = "Recall Back"
        }

    mode_button.callback = function()
        self.mode = (self.mode + 1) % 3
---@diagnostic disable-next-line: undefined-field
        if(not self.free_play.selected_cards.reversible) then
            self.mode = 0
        end
        mode_button.front_text = ({[0] = "Recall Back", "Recall Front", "Recall Both"})[self.mode]
        mode_button:rerender()
    end

    self.mode = 0
    self.buttons = {play_button, mode_button, play_button_2}

    -- card set buttons

    local card_sets = {}
    for i, file in ipairs(love.filesystem.getDirectoryItems("card_sets")) do
        local path = "card_sets/" .. file
        local card_set = require("card_sets." .. file:gsub("%.lua", ""))
        table.insert(self.buttons, FlashcardButton{
            transform = Transform{
                position = SCREEN_SIZE * vec2(0.12, 0.45 + i * 0.05),
                size = vec2(320, 50),
                scale = vec2(0.5, 0.5)
            },
            text = card_set.name .. " (" .. #card_set.cards .. ")",
            callback = function()
                self.free_play.selected_cards = card_set

                ---@diagnostic disable-next-line: undefined-field
                if(not self.free_play.selected_cards.reversible) then
                    self.mode = 0
                    mode_button.front_text = ({[0] = "Recall Back", "Recall Front", "Recall Both"})[self.mode]
                    mode_button:rerender()
                end
            end
        })
        table.insert(card_sets, card_set)
        -- Select first game/card set by default
        if(self.free_play.selected_cards == nil) then
            self.free_play.selected_cards = card_set
        end
    end

    local games = {}
    for i, file in ipairs(love.filesystem.getDirectoryItems("games")) do
        local path = "games/" .. file
        local game = require("games." .. file:gsub("%.lua", ""))
        table.insert(self.buttons, FlashcardButton{
            transform = Transform{
                position = SCREEN_SIZE * vec2(0.38, 0.45 + i * 0.05),
                size = vec2(320, 50),
                scale = vec2(0.5, 0.5)
            },
            text = game.name,
            callback = function()
                self.free_play.selected_game = game
            end
        })
        table.insert(games, game)
        -- Select first game/card set by default
        if(self.free_play.selected_game == nil) then
            self.free_play.selected_game = game
        end
    end

    self.challenge = {
        selected_game = games[math.random(#games)],
        selected_cards = card_sets[math.random(#card_sets)]
    }
    self.challenge.mode = self.challenge.selected_cards.reversible and math.random(1, 3) or 0
end

function MenuScene:update(dt)
    for _, button in pairs(self.buttons) do
        button:update(dt)
    end
end

function MenuScene:draw()
    local SCREEN_SIZE = vec2(love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.clear(0.9, 0.9, 1)

    love.graphics.setFont(Fonts[48])
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("Welcome!", 0, SCREEN_SIZE.y * 0.1, SCREEN_SIZE.x, "center")
    love.graphics.setFont(Fonts[24])
    love.graphics.printf("Are you ready for your next challenge?", 0, SCREEN_SIZE.y * 0.2, SCREEN_SIZE.x, "center")
    
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.line(SCREEN_SIZE.x*0.5, SCREEN_SIZE.y*0.3, SCREEN_SIZE.x*0.5, SCREEN_SIZE.y*0.9)

    -- left column
    love.graphics.setFont(Fonts[32])
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("FREE PLAY", 0, SCREEN_SIZE.y * 0.33, SCREEN_SIZE.x*0.5, "center")
    love.graphics.setFont(Fonts[16])
    love.graphics.printf("Practice your cards with your own rules!", 0, SCREEN_SIZE.y * 0.4, SCREEN_SIZE.x*0.5, "center")

    love.graphics.setFont(Fonts[12])
---@diagnostic disable-next-line: undefined-field
    love.graphics.printf("High Score: " .. get_high_score(self.free_play.selected_cards.name, self.free_play.selected_game.name, self.mode), 0, SCREEN_SIZE.y * 0.8, SCREEN_SIZE.x*0.5, "center")


    -- right column
    love.graphics.setFont(Fonts[32])
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("DAILY CHALLENGE", SCREEN_SIZE.x*0.5, SCREEN_SIZE.y * 0.33, SCREEN_SIZE.x*0.5, "center")
    love.graphics.setFont(Fonts[16])
    love.graphics.printf("Can you reach the top of the tower?", SCREEN_SIZE.x*0.5, SCREEN_SIZE.y * 0.4, SCREEN_SIZE.x*0.5, "center")
    love.graphics.setFont(Fonts[12])
    love.graphics.printf("Today's Challenge:\n" .. self.challenge.selected_game.name .. "\n" .. self.challenge.selected_cards.name .. "\n" .. ({[0]="Recall Back", "Recall Front", "Recall Both"})[self.challenge.mode], SCREEN_SIZE.x*0.5 + 10, SCREEN_SIZE.y * 0.55, SCREEN_SIZE.x*0.5 - 20, "left")

    -- draw tower
    local function pingpong(a, b, x)
        if(x % 2 < 1) then
            return a + (b-a) * (x % 2)
        else
            return b + (a-b) * ((x % 2) - 1)
        end
    end

    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.setFont(Fonts[12])
    for i=0, 11 do
        local sy, ey = SCREEN_SIZE.y * 0.9 - (SCREEN_SIZE.y * 0.3 * i/8), SCREEN_SIZE.y * 0.9 - (SCREEN_SIZE.y * 0.3 * (i+1)/8)
        local sx, ex = pingpong(SCREEN_SIZE.x * 0.55, SCREEN_SIZE.x * 0.95, i/7), pingpong(SCREEN_SIZE.x * 0.55, SCREEN_SIZE.x * 0.95, (i+1)/7)
        love.graphics.line(sx, sy, ex, sy, ex, ey)
        love.graphics.printf(tostring(i), math.min(sx, ex), sy - 18, math.abs(ex-sx), "center")
        if(i == SAVE_DATA.streak) then
            love.graphics.setColor(0, 0, 0, 0.5)
            love.graphics.line(ex + 10, sy, SCREEN_SIZE.x, sy)
            love.graphics.printf("Current Streak: " .. SAVE_DATA.streak, ex, sy - 18, math.abs(SCREEN_SIZE.x - ex - 10), "right")
            love.graphics.setColor(0, 0, 0, 0.7)
        end
    end

    for _, button in pairs(self.buttons) do
        button:draw()
    end
end

function MenuScene:keypressed(key, code, rept)

end

function MenuScene:keyreleased(key, code)

end

function MenuScene:mousepressed()
    for _, button in pairs(self.buttons) do
        button:onClick()
    end
end

return MenuScene