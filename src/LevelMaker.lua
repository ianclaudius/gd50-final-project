--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class{}

function LevelMaker.generate(width, height)
    local tiles = {}
    local entities = {}
    local objects = {}

    local tileID = TILE_ID_GROUND
    
    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)

    -- generate matching lock and key at random position
    local lockPosition = math.random(10, width - 10)
    local lockFrame = math.random(5, 8)
    local keyFrame = lockFrame - 4

    -- goal post to increment level, matching color of lock and key
    local poleFrame = keyFrame + 2
    local flagFrame = keyFrame * 3
    local goalPosition = width - 1

    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        local tileID = TILE_ID_EMPTY
        
        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- chance to just be emptiness, except below player spawn, lock box, or level end
        if x > 1 and x < goalPosition - 1 and x ~= lockPosition and math.random(7) == 1 then
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
        else
            tileID = TILE_ID_GROUND

            -- height at which we would spawn a potential jump block
            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            -- chance to generate a pillar
            if x < goalPosition - 1 and math.random(8) == 1 then
                blockHeight = 2
                
                -- chance to generate bush on pillar
                if math.random(8) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,
                            
                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                            collidable = false
                        }
                    )
                end
                
                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil
            
            -- chance to generate bushes
            elseif math.random(8) == 1 then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        collidable = false
                    }
                )
            end

            -- chance to spawn a block, ensuring that it's not overlapping a lock box or flag
            if x ~= lockPosition and x < goalPosition - 1 and math.random(10) == 1 then
                table.insert(objects,

                    -- jump block
                    GameObject {
                        texture = 'jump-blocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- make it a random variant
                        frame = math.random(#JUMP_BLOCKS),
                        collidable = true,
                        hit = false,
                        solid = true,

                        -- collision function takes itself
                        onCollide = function(obj)

                            -- spawn a gem if we haven't already hit the block
                            if not obj.hit then

                                -- chance to spawn gem, not guaranteed
                                if math.random(5) == 1 then

                                    -- maintain reference so we can set it to nil
                                    local gem = GameObject {
                                        texture = 'gems',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = math.random(#GEMS),
                                        collidable = true,
                                        consumable = true,
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.score = player.score + 100
                                        end
                                    }
                                    
                                    -- make the gem move up from the block and play a sound
                                    Timer.tween(0.1, {
                                        [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, gem)
                                end

                                obj.hit = true
                            end

                            gSounds['empty-block']:play()
                        end
                    }
                )
            end

            -- spawn matching lock and key
            if x == lockPosition then
                table.insert(objects,

                    -- lock block
                    GameObject {
                        texture = 'keys-locks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = lockFrame,
                        collidable = true,
                        consumable = false,
                        hit = false,
                        solid = true,
                        onCollide = function(obj)

                            -- spawn a key if we haven't yet
                            if not obj.hit then
                                local key = GameObject {
                                    texture = 'keys-locks',
                                    x = (x - 1) * TILE_SIZE,
                                    y = (blockHeight - 1) * TILE_SIZE - 4,
                                    width = 16,
                                    height = 16,
                                    frame = keyFrame,
                                    collidable = true,
                                    consumable = true,
                                    solid = false,
                                    onConsume = function(player, object)
                                        gSounds['pickup']:play()
                                        hasKey = true
                                        obj.solid = false
                                        obj.consumable = true
                                    end
                                }
                                
                                Timer.tween(0.1, {
                                    [key] = {y = (blockHeight - 2) * TILE_SIZE}
                                })
                                gSounds['powerup-reveal']:play()

                                table.insert(objects, key)

                                obj.hit = true
                            end

                            gSounds['empty-block']:play()
                        end,
                        
                        -- once unlocked, create goal and allow level progression
                        onConsume = function(player, object)
                            gSounds['unlock']:play()
                            hasKey = false

                            -- spawn pole
                            table.insert(objects,
                                GameObject {
                                    texture = 'poles',
                                    x = goalPosition * TILE_SIZE - TILE_SIZE / 2,
                                    y = (blockHeight - 1) * TILE_SIZE,
                                    width = 16,
                                    height = 48,
                                    frame = poleFrame,
                                }
                            )

                            --spawn flag
                            table.insert(objects,
                                GameObject {
                                    texture = 'flags',
                                    x = goalPosition * TILE_SIZE,
                                    y = (blockHeight - 1) * TILE_SIZE,
                                    width = 16,
                                    height = 16,
                                    frame = flagFrame,
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
                        end
                    }
                )
            end
        end
    end

    local map = TileMap(width, height)
    map.tiles = tiles
    
    return GameLevel(entities, objects, map)
end