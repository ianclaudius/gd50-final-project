--[[
    GD50
    Super Mario Bros. Remake

    -- BeeIdleState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

BeeIdleState = Class{__includes = BaseState}

function BeeIdleState:init(tilemap, player, bee)
    self.tilemap = tilemap
    self.player = player
    self.bee = bee
    self.waitTimer = 0
    self.animation = Animation {
        frames = {46},
        interval = 1
    }
    self.bee.currentAnimation = self.animation
end

function BeeIdleState:enter(params)
    self.waitPeriod = params.wait
end

function BeeIdleState:update(dt)
    if self.waitTimer < self.waitPeriod then
        self.waitTimer = self.waitTimer + dt
    else
        self.bee:changeState('moving')
    end

    -- calculate difference between bee and player on X axis
    local diffX = math.abs(self.player.x - self.bee.x)

    if diffX < 20 * TILE_SIZE then
        self.bee:changeState('chasing')
    end
end