--[[
    GD50
    Super Mario Bros. Remake

    -- PlayerFallingState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerFallingState = Class{__includes = BaseState}

function PlayerFallingState:init(player, gravity)
    self.player = player
    self.gravity = gravity
    self.animation = Animation {
        frames = {3},
        interval = 1
    }
    self.player.currentAnimation = self.animation
end

function PlayerFallingState:update(dt)
    self.player.currentAnimation:update(dt)
    self.player.dy = self.player.dy + self.gravity
    self.player.y = self.player.y + (self.player.dy * dt)

    -- look at two tiles below our feet and check for collisions
    local tileBottomLeft = self.player.map:pointToTile(self.player.x + 1, self.player.y + self.player.height)
    local tileBottomRight = self.player.map:pointToTile(self.player.x + self.player.width - 1, self.player.y + self.player.height)

    -- if we get a collision beneath us, go into either walking or idle
    if (tileBottomLeft and tileBottomRight) and (tileBottomLeft:collidable() or tileBottomRight:collidable()) then
        self.player.dy = 0
        
        -- set the player to be walking or idle on landing depending on input
        if love.keyboard.isDown('left') or love.keyboard.isDown('right') then
            self.player:changeState('walking')
        else
            self.player:changeState('idle')
        end

        self.player.y = (tileBottomLeft.y - 1) * TILE_SIZE - self.player.height
    
    -- go back to start if we fall below the map boundary
    elseif self.player.y > VIRTUAL_HEIGHT then
        -- upon death, player can continue where they left off, but loses half their points
        gSounds['death']:play()
        gStateMachine:change('play', {
            score = self.player.score / 2,
            levelNumber = self.player.levelNumber
        })

        -- can be re-enabled if starting over at level 1 is preferred
        -- gStateMachine:change('start')
    
    -- check side collisions and reset position
    elseif love.keyboard.isDown('left') then
        self.player.direction = 'left'
        self.player.x = self.player.x - PLAYER_WALK_SPEED * dt
        self.player:checkLeftCollisions(dt)
    elseif love.keyboard.isDown('right') then
        self.player.direction = 'right'
        self.player.x = self.player.x + PLAYER_WALK_SPEED * dt
        self.player:checkRightCollisions(dt)
    end

    -- check if we've collided with any collidable game objects
    for k, object in pairs(self.player.level.objects) do
        if object:collides(self.player) then
            if object.solid then
                self.player.dy = 0
                self.player.y = object.y - self.player.height

                if love.keyboard.isDown('left') or love.keyboard.isDown('right') then
                    self.player:changeState('walking')
                else
                    self.player:changeState('idle')
                end
            elseif object.consumable then
                object.onConsume(self.player)
                table.remove(self.player.level.objects, k)
            end
        end
    end

    -- check if we've collided with any entities and kill them if so
    for k, entity in pairs(self.player.level.entities) do
        if entity:collides(self.player) then
            
            -- for bosses
            if entity.boss then

                gSounds['boss-kill']:play()

                -- scale boss reward with level
                self.player.score = self.player.score + self.player.levelNumber * 100

                -- player must kill boss to reveal goal and advance
                table.insert(self.player.level.objects,
                    GameObject {
                        texture = 'poles',
                        x = 49 * TILE_SIZE - TILE_SIZE / 2,
                        y = 3 * TILE_SIZE,
                        width = 16,
                        height = 48,
                        frame = 3,
                    }
                )

                table.insert(self.player.level.objects,
                    GameObject {
                        texture = 'flags',
                        x = 49 * TILE_SIZE,
                        y = 3 * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = 9,
                        collidable = true,
                        consumable = true,
                        solid = false,
                        
                        -- advance to next level
                        onConsume = function(player, object)
                            gSounds['level']:play()
                            gStateMachine:change('play', {
                                score = player.score,
                                levelNumber = player.levelNumber + 1
                            })
                        end
                    }
                )
            
            -- for other enemies
            else
                gSounds['kill']:play()
                gSounds['kill2']:play()
                self.player.score = self.player.score + 100
            end

            table.remove(self.player.level.entities, k)
        end
    end
end