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

    self.movingDirection = 'right'
    self.boss.direction = self.movingDirection
    self.movingDuration = math.random(5)
    self.movingTimer = 0

    self.beeTimer = 0
end

function BossMovingState:update(dt)
    self.movingTimer = self.movingTimer + dt
    self.boss.currentAnimation:update(dt)

    -- reset movement direction and timer if timer is above duration
    if self.boss.direction == 'left' then
        self.boss.x = self.boss.x - BOSS_CHASE_SPEED * dt

        -- stop the boss if there's a missing tile on the floor to the left or a solid tile directly left
        local tileLeft = self.tilemap:pointToTile(self.boss.x, self.boss.y)
        local tileBottomLeft = self.tilemap:pointToTile(self.boss.x, self.boss.y + self.boss.height)

        if (tileLeft and tileBottomLeft) and (tileLeft:collidable() or not tileBottomLeft:collidable()) then
            self.boss.x = self.boss.x + BOSS_RETREAT_SPEED * dt

            -- reset direction if we hit a wall
            self.movingDirection = 'right'
            self.boss.direction = self.movingDirection
            self.movingDuration = math.random(5)
            self.movingTimer = 0
        end
    else
        self.boss.direction = 'right'
        self.boss.x = self.boss.x + BOSS_RETREAT_SPEED * dt

        -- stop the boss if there's a missing tile on the floor to the right or a solid tile directly right
        local tileRight = self.tilemap:pointToTile(self.boss.x + self.boss.width, self.boss.y)
        local tileBottomRight = self.tilemap:pointToTile(self.boss.x + self.boss.width, self.boss.y + self.boss.height)

        if (tileRight and tileBottomRight) and (tileRight:collidable() or not tileBottomRight:collidable()) then
            self.boss.x = self.boss.x - BOSS_CHASE_SPEED * dt

            -- reset direction if we hit a wall
            self.movingDirection = 'left'
            self.boss.direction = self.movingDirection
            self.movingDuration = math.random(5)
            self.movingTimer = 0
        end
    end

    -- calculate difference between boss and player on X axis and only chase if very close
    local diffX = math.abs(self.player.x - self.boss.x)

    if diffX < 2 * TILE_SIZE then
        self.boss:changeState('chasing')
    end

    -- timer.every() had some unexpected behavior, so constructing a simpler timer
    self.beeTimer = self.beeTimer + dt

    -- bee spawn rate (and thus boss difficulty), scales with level
    if self.beeTimer >= 12 / self.player.levelNumber then
        self:spawnBees(self.boss.x)
        self.beeTimer = 0
    end
end

function BossMovingState:spawnBees(loc)
    -- bees are essentially living projectiles that spawn from the boss
    local bee
    bee = Bee {
        texture = 'creatures',
        x = loc,
        y = TILE_SIZE * 5,
        width = 16,
        height = 16,
        boss = false,
        stateMachine = StateMachine {
            ['idle'] = function() return BeeIdleState(self.tilemap, self.player, bee) end,
            ['moving'] = function() return BeeMovingState(self.tilemap, self.player, bee) end,
            ['chasing'] = function() return BeeChasingState(self.tilemap, self.player, bee) end
        }
    }
    bee:changeState('chasing')

    table.insert(self.player.level.entities, bee)
end