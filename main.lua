local Flashcard = require "components.flashcard"
local Transform = require "components.transform2d"
local vec2 = require "components.vec2"
local SceneStack = require "scene_stack"
local Events = require "event"
local binser = require "lib.binser"
love.filesystem.setIdentity("cardshark")
math.randomseed(os.clock())

local card_blast_scene = require "games.card_blast"
--SceneStack:push_scene(card_blast_scene(require "card_sets.simple_addition"))
SceneStack:push_scene((require "scenes.main_menu")())

-- initial save data
if(true) then
    SAVE_DATA = {
        streak = 0,
        high_scores = { -- high_scores.[card_set].[mode]

        }
    }
    
    --binser.writeFile("progress.cs", SAVE_DATA)
end

function get_high_score(card_set, game, mode)
    if(not SAVE_DATA.high_scores[card_set]) then
        SAVE_DATA.high_scores[card_set] = {}
    end
    if(not SAVE_DATA.high_scores[card_set][game]) then
        SAVE_DATA.high_scores[card_set][game] = {}
    end
    if(not SAVE_DATA.high_scores[card_set][game][mode]) then
        SAVE_DATA.high_scores[card_set][game][mode] = 0
    end
    return SAVE_DATA.high_scores[card_set][game][mode]
end

function set_high_score(card_set, game, mode, score)
    if(not SAVE_DATA.high_scores[card_set]) then
        SAVE_DATA.high_scores[card_set] = {}
    end
    if(not SAVE_DATA.high_scores[card_set][game]) then
        SAVE_DATA.high_scores[card_set][game] = {}
    end
    SAVE_DATA.high_scores[card_set][game][mode] = score
end

function love.update(dt)
    Events:update(dt)
    SceneStack:update(dt)
end

function love.draw()
    SceneStack:draw()
end

function love.keypressed(key, scancode, rept)
    SceneStack:on_keypress(key, scancode, rept)
end

function love.keyreleased(key, scancode)
    SceneStack:on_keyrelease(key, scancode)
end

function love.mousepressed()
    SceneStack:mousepressed()
end