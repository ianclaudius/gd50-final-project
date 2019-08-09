--[[
    GD50
    Super Mario Bros. Remake

    -- BeeMovingState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

BeeMovingState = Class{__includes = BaseState}

function BeeMovingState:init(tilemap, player, bee)
    self.tilemap = tilemap
    self.player = player
    self.bee = bee
    self.animation = Animation {
        frames = {44, 45},
        interval = 0.5
    }
    self.bee.currentAnimation = self.animation

    self.movingDirection = math.random(2) == 1 and 'left' or 'right'
    self.bee.direction = self.movingDirection
    self.movingDuration = math.random(5)
    self.movingTimer = 0
end

function BeeMovingState:update(dt)
    self.movingTimer = self.movingTimer + dt
    self.bee.currentAnimation:update(dt)

    -- reset movement direction and timer if timer is above duration
    if self.movingTimer > self.movingDuration then

        -- chance to go into idle state randomly
        if math.random(4) == 1 then
            self.bee:changeState('idle', {

                -- random amount of time for bee to be idle
                wait = math.random(5)
            })
        else
            self.movingDirection = math.random(2) == 1 and 'left' or 'right'
            self.bee.direction = self.movingDirection
            self.movingDuration = math.random(5)
            self.movingTimer = 0
        end
    elseif self.bee.direction == 'left' then
        self.bee.x = self.bee.x - BEE_MOVE_SPEED * dt

        -- stop the bee if there's a missing tile on the floor to the left or a solid tile directly left
        local tileLeft = self.tilemap:pointToTile(self.bee.x, self.bee.y)
        local tileBottomLeft = self.tilemap:pointToTile(self.bee.x, self.bee.y + self.bee.height)

        if (tileLeft and tileBottomLeft) and (tileLeft:collidable() or not tileBottomLeft:collidable()) then
            self.bee.x = self.bee.x + BEE_MOVE_SPEED * dt

            -- reset direction if we hit a wall
            self.movingDirection = 'right'
            self.bee.direction = self.movingDirection
            self.movingDuration = math.random(5)
            self.movingTimer = 0
        end
    else
        self.bee.direction = 'right'
        self.bee.x = self.bee.x + BEE_MOVE_SPEED * dt

        -- stop the bee if there's a missing tile on the floor to the right or a solid tile directly right
        local tileRight = self.tilemap:pointToTile(self.bee.x + self.bee.width, self.bee.y)
        local tileBottomRight = self.tilemap:pointToTile(self.bee.x + self.bee.width, self.bee.y + self.bee.height)

        if (tileRight and tileBottomRight) and (tileRight:collidable() or not tileBottomRight:collidable()) then
            self.bee.x = self.bee.x - BEE_MOVE_SPEED * dt

            -- reset direction if we hit a wall
            self.movingDirection = 'left'
            self.bee.direction = self.movingDirection
            self.movingDuration = math.random(5)
            self.movingTimer = 0
        end
    end

    -- calculate difference between bee and player on X axis
    local diffX = math.abs(self.player.x - self.bee.x)

    if diffX < 5 * TILE_SIZE then
        self.bee:changeState('chasing')
    end
end