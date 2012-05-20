-- -----------------------------------------------------------------------------
local tileSize = 32

local tilesDisplayW = 25
local tilesDisplayH = 19

local chunkW = 32
local chunkH = 32

local tilesetImage
local tilesetQuads = {}
local chunkMap

local mapX, mapY

-- -----------------------------------------------------------------------------
function love.load()
   mapX = 1.10
   mapY = 1.10
   image = love.graphics.newImage( "gfx/wizard.png" )
   tilesetImage = love.graphics.newImage( "gfx/t_00.png" )

   index = 0
   for j = 0, (tilesetImage:getHeight() / tileSize) - 1 do
      for i = 0, (tilesetImage:getWidth() / tileSize) - 1 do
	 tilesetQuads[index] = love.graphics.newQuad(
	    i * tileSize, j * tileSize, tileSize, tileSize,
	    tilesetImage:getWidth(), tilesetImage:getHeight() )
	 index = index + 1
      end
   end

   chunkMap = {}
   for x = 0, chunkW - 1 do
      chunkMap[x] = {}
      for y = 0, chunkH - 1 do
	 chunkMap[x][y] = math.random(0,16)
      end
   end

   tilesetBatch = love.graphics.newSpriteBatch(
      tilesetImage, tilesDisplayW * tilesDisplayH )

   updateTilesetBatch()
end

-- -----------------------------------------------------------------------------
function updateTilesetBatch()
   tilesetBatch:clear()
   for x = 0, tilesDisplayW-1 do
      for y = 0, tilesDisplayH-1 do
	 index = chunkMap[x+math.floor(mapX)][y+math.floor(mapY)]
	 tilesetBatch:addq(
	    tilesetQuads[index], x*tileSize, y*tileSize )
    end
  end
end

-- -----------------------------------------------------------------------------
function moveMap( dx, dy )
   oldMapX = mapX
   oldMapY = mapY
   mapX = math.max(math.min(mapX + dx, chunkW - tilesDisplayW), 1)
   mapY = math.max(math.min(mapY + dy, chunkH - tilesDisplayH), 1)
   -- only update if we actually moved
   neqX = math.floor(mapX) ~= math.floor(oldMapX)
   neqY = math.floor(mapY) ~= math.floor(oldMapY)
   if neqX or neqY then
      updateTilesetBatch()
   end
end

-- -----------------------------------------------------------------------------
function love.update( dt )
   if love.keyboard.isDown("up") then
      moveMap( 0, -0.2 * tileSize * dt)
   end
   if love.keyboard.isDown("down") then
      moveMap( 0, 0.2 * tileSize * dt)
   end
   if love.keyboard.isDown("left") then
      moveMap( -0.2 * tileSize * dt, 0)
   end
   if love.keyboard.isDown("right") then
      moveMap( 0.2 * tileSize * dt, 0)
   end
end

-- -----------------------------------------------------------------------------
function love.draw()
   offsetx = math.floor((mapX%1)*tileSize)
   offsety = math.floor((mapY%1)*tileSize)
   love.graphics.draw( tilesetBatch, offsetx, offsety )
   love.graphics.draw( image,
		       love.graphics:getWidth()/2,
		       love.graphics:getHeight()/2 )
end

-- -----------------------------------------------------------------------------
