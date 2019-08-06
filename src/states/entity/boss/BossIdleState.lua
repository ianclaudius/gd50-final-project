--[[
    GD50
    Super Mario Bros. Remake

    -- BossIdleState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

BossIdleState = Class{__includes = BaseState}

function BossIdleState:init(tilemap, player, boss)
    self.tilemap = tilemap
    self.player = player
    self.boss = boss
    self.waitTimer = 0
    self.animation = Animation {
        frames = {3},
        interval = 1
    }
    self.boss.currentAnimation = self.animation
end

function BossIdleState:enter(params)
    self.waitPeriod = params.wait
end

function BossIdleState:update(dt)
    if self.waitTimer < self.waitPeriod then
        self.waitTimer = self.waitTimer + dt
    else
        self.boss:changeState('moving')
    end

    -- calculate difference between boss and player on X axis
    -- and only chase if <= 5 tiles
    local diffX = math.abs(self.player.x - self.boss.x)

    if diffX < 5 * TILE_SIZE then
        self.boss:changeState('chasing')
    end
end