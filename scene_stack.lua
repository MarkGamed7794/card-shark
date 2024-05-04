local SceneStack = {scenes = {}}
local binser = require "lib.binser"

function SceneStack:push_scene(scene)
    table.insert(self.scenes, scene)
    scene:init()
end

function SceneStack:pop_scene()
    table.remove(self.scenes)
    --love.filesystem.write("progress.cs", binser.serialize(SAVE_DATA))
end

function SceneStack:getCurrentScene(depth)
    return self.scenes[#self.scenes - (depth or 0)]
end

function SceneStack:on_keypress(key, scancode, rept)
    local current_scene = self:getCurrentScene()
    if(current_scene) then
        current_scene:keypressed(key, scancode, rept)
    end
end

function SceneStack:on_keyrelease(key, scancode)
    local current_scene = self:getCurrentScene()
    if(current_scene) then
        current_scene:keyreleased(key, scancode)
    end
end

function SceneStack:update(dt)
    local current_scene = self:getCurrentScene()
    if(current_scene) then
        current_scene:update(dt)
    end
end

function SceneStack:draw()
    local current_scene = self:getCurrentScene()
    if(current_scene) then
        current_scene:draw()
    end
end

function SceneStack:mousepressed()
    local current_scene = self:getCurrentScene()
    if(current_scene and current_scene.mousepressed) then
        current_scene:mousepressed()
    end
end



return SceneStack