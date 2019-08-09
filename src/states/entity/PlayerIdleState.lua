--[[
    GD50
    Super Mario Bros. Remake

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerIdleState = Class{__includes = BaseState}

function PlayerIdleState:init(player)
    self.player = player

    self.animation = Animation {
        frames = {1},
        interval = 1
    }

    self.player.currentAnimation = self.animation
end

function PlayerIdleState:update(dt)
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') then
        self.player:changeState('walking')
    end

    if love.keyboard.wasPressed('space') then
        self.player:changeState('jump')
    end

    -- check if we've collided with any entities and die if so
    for k, entity in pairs(self.player.level.entities) do
        if entity:collides(self.player) then
            -- upon death, player can continue where they left off, but loses half their points
            gSounds['death']:play()
            gStateMachine:change('play', {
                score = self.player.score / 2,
                levelNumber = self.player.levelNumber
            })

            -- can be re-enabled if starting over at level 1 is preferred
            -- gStateMachine:change('start')
        end
    end
end