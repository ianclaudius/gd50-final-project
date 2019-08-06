--[[
    GD50
    Super Mario Bros. Remake

    -- BossMovingState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

BossMovingState = Class{__includes = BaseState}

function BossMovingState:init(tilemap, player, boss)
    self.tilemap = tilemap
    self.player = player
    self.boss = boss
    self.animation = Animation {
        frames = {1, 2},
        interval = 1.5
    }
    self.boss.currentAnimation = self.animation

    self.movingDirection = math.random(2) == 1 and 'left' or 'right'
    self.boss.direction = self.movingDirection
    self.movingDuration = math.random(5)
    self.movingTimer = 0
end

function BossMovingState:update(dt)
    self.movingTimer = self.movingTimer + dt
    self.boss.currentAnimation:update(dt)

    -- reset movement direction and timer if timer is above duration
    if self.movingTimer > self.movingDuration then

        -- chance to go into idle state randomly
        if math.random(4) == 1 then
            self.boss:changeState('idle', {

                -- random amount of time for boss to be idle
                wait = math.random(5)
            })
        else
            self.movingDirection = math.random(2) == 1 and 'left' or 'right'
            self.boss.direction = self.movingDirection
            self.movingDuration = math.random(5)
            self.movingTimer = 0
        end
    elseif self.boss.direction == 'left' then
        self.boss.x = self.boss.x - BOSS_MOVE_SPEED * dt

        -- stop the boss if there's a missing tile on the floor to the left or a solid tile directly left
        local tileLeft = self.tilemap:pointToTile(self.boss.x, self.boss.y)
        local tileBottomLeft = self.tilemap:pointToTile(self.boss.x, self.boss.y + self.boss.height)

        if (tileLeft and tileBottomLeft) and (tileLeft:collidable() or not tileBottomLeft:collidable()) then
            self.boss.x = self.boss.x + BOSS_MOVE_SPEED * dt

            -- reset direction if we hit a wall
            self.movingDirection = 'right'
            self.boss.direction = self.movingDirection
            self.movingDuration = math.random(5)
            self.movingTimer = 0
        end
    else
        self.boss.direction = 'right'
        self.boss.x = self.boss.x + BOSS_MOVE_SPEED * dt

        -- stop the boss if there's a missing tile on the floor to the right or a solid tile directly right
        local tileRight = self.tilemap:pointToTile(self.boss.x + self.boss.width, self.boss.y)
        local tileBottomRight = self.tilemap:pointToTile(self.boss.x + self.boss.width, self.boss.y + self.boss.height)

        if (tileRight and tileBottomRight) and (tileRight:collidable() or not tileBottomRight:collidable()) then
            self.boss.x = self.boss.x - BOSS_MOVE_SPEED * dt

            -- reset direction if we hit a wall
            self.movingDirection = 'left'
            self.boss.direction = self.movingDirection
            self.movingDuration = math.random(5)
            self.movingTimer = 0
        end
    end

    -- calculate difference between boss and player on X axis
    -- and only chase if <= 5 tiles
    local diffX = math.abs(self.player.x - self.boss.x)

    if diffX < 5 * TILE_SIZE then
        self.boss:changeState('chasing')
    end
end