--[[
    GD50
    Super Mario Bros. Remake

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

BossChasingState = Class{__includes = BaseState}

function BossChasingState:init(tilemap, player, boss)
    self.tilemap = tilemap
    self.player = player
    self.boss = boss
    self.animation = Animation {
        frames = {1, 2},
        interval = 1.5
    }
    self.boss.currentAnimation = self.animation
end

function BossChasingState:update(dt)
    self.boss.currentAnimation:update(dt)

    -- calculate difference between boss and player on X axis
    -- and only chase if <= 5 tiles
    local diffX = math.abs(self.player.x - self.boss.x)

    if diffX > 5 * TILE_SIZE then
        self.boss:changeState('moving')
    elseif self.player.x < self.boss.x then
        self.boss.direction = 'left'
        self.boss.x = self.boss.x - BOSS_MOVE_SPEED * dt

        -- stop the boss if there's a missing tile on the floor to the left or a solid tile directly left
        local tileLeft = self.tilemap:pointToTile(self.boss.x, self.boss.y)
        local tileBottomLeft = self.tilemap:pointToTile(self.boss.x, self.boss.y + self.boss.height)

        if (tileLeft and tileBottomLeft) and (tileLeft:collidable() or not tileBottomLeft:collidable()) then
            self.boss.x = self.boss.x + BOSS_MOVE_SPEED * dt
        end
    else
        self.boss.direction = 'right'
        self.boss.x = self.boss.x + BOSS_MOVE_SPEED * dt

        -- stop the boss if there's a missing tile on the floor to the right or a solid tile directly right
        local tileRight = self.tilemap:pointToTile(self.boss.x + self.boss.width, self.boss.y)
        local tileBottomRight = self.tilemap:pointToTile(self.boss.x + self.boss.width, self.boss.y + self.boss.height)

        if (tileRight and tileBottomRight) and (tileRight:collidable() or not tileBottomRight:collidable()) then
            self.boss.x = self.boss.x - BOSS_MOVE_SPEED * dt
        end
    end
end