--[[
    GD50
    Super Mario Bros. Remake

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

BeeChasingState = Class{__includes = BaseState}

function BeeChasingState:init(tilemap, player, bee)
    self.tilemap = tilemap
    self.player = player
    self.bee = bee
    self.animation = Animation {
        frames = {44, 45},
        interval = 0.5
    }
    self.bee.currentAnimation = self.animation
end

function BeeChasingState:update(dt)
    self.bee.currentAnimation:update(dt)

    -- calculate difference between bee and player on X axis
    -- and only chase if <= 5 tiles
    local diffX = math.abs(self.player.x - self.bee.x)

    if diffX > 5 * TILE_SIZE then
        self.bee:changeState('moving')
    elseif self.player.x < self.bee.x then
        self.bee.direction = 'left'
        self.bee.x = self.bee.x - BEE_MOVE_SPEED * dt

        -- stop the bee if there's a missing tile on the floor to the left or a solid tile directly left
        local tileLeft = self.tilemap:pointToTile(self.bee.x, self.bee.y)
        local tileBottomLeft = self.tilemap:pointToTile(self.bee.x, self.bee.y + self.bee.height)

        if (tileLeft and tileBottomLeft) and (tileLeft:collidable() or not tileBottomLeft:collidable()) then
            self.bee.x = self.bee.x + BEE_MOVE_SPEED * dt
        end
    else
        self.bee.direction = 'right'
        self.bee.x = self.bee.x + BEE_MOVE_SPEED * dt

        -- stop the bee if there's a missing tile on the floor to the right or a solid tile directly right
        local tileRight = self.tilemap:pointToTile(self.bee.x + self.bee.width, self.bee.y)
        local tileBottomRight = self.tilemap:pointToTile(self.bee.x + self.bee.width, self.bee.y + self.bee.height)

        if (tileRight and tileBottomRight) and (tileRight:collidable() or not tileBottomRight:collidable()) then
            self.bee.x = self.bee.x - BEE_MOVE_SPEED * dt
        end
    end
end