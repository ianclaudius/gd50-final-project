--[[
    GD50
    Super Mario Bros. Remake

    -- Boss Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Boss = Class{__includes = Entity}

function Boss:init(def)
    Entity.init(self, def)
    self.boss = true
end

function Boss:render()
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.currentAnimation:getCurrentFrame()],
        math.floor(self.x) + 8, math.floor(self.y) + 8, 0, self.direction == 'left' and 1 or -1, 1, 8, 10)
end