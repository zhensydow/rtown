-- -----------------------------------------------------------------------------
local ATL = require("AdvTiledLoader")

-- -----------------------------------------------------------------------------
local TILESIZE = 32
local SCR_CENTER_X
local SCR_CENTER_Y

local tilesDisplayW = 26
local tilesDisplayH = 20

local chunkW = 32
local chunkH = 32

local player_offX = 0
local player_offY = 0

local player_tileX = 1
local player_tileY = 1

local sel_tileX = 0
local sel_tileY = 0

-- -----------------------------------------------------------------------------
function loadMap( name )
   local map

   map = ATL.Loader.load("chunk01.tmx")

   if map.tl["collision"] then
      map.tl["collision"].opacity = 0
   end

   return map
end

-- -----------------------------------------------------------------------------
function love.load()
   SCR_CENTER_X = love.graphics:getWidth()/2
   SCR_CENTER_Y = love.graphics:getHeight()/2
   image = love.graphics.newImage( "gfx/wizard.png" )


   ATL.Loader.path = 'gfx/'
   atlMap1 = loadMap("chunk01.tmx")
   atlMap2 = loadMap("chunk02.tmx")

end

-- -----------------------------------------------------------------------------
function moveMap( dx, dy )
   player_offX = player_offX + dx
   player_offY = player_offY + dy
end

-- -----------------------------------------------------------------------------
function love.update( dt )
   local spd = 10
   if love.keyboard.isDown("up") then
      moveMap( 0, spd * TILESIZE * dt)
   end
   if love.keyboard.isDown("down") then
      moveMap( 0, - spd * TILESIZE * dt)
   end
   if love.keyboard.isDown("left") then
      moveMap( spd * TILESIZE * dt, 0)
   end
   if love.keyboard.isDown("right") then
      moveMap( - spd * TILESIZE * dt, 0)
   end
end

-- -----------------------------------------------------------------------------
function love.draw()
   love.graphics.setColor( 255, 255, 255 )
   love.graphics.push()
   love.graphics.translate(
      SCR_CENTER_X - TILESIZE - 16 + player_offX - TILESIZE*player_tileX,
      SCR_CENTER_Y - TILESIZE - 16 + player_offY - TILESIZE*player_tileY )
   atlMap1:draw()
   love.graphics.pop()

--   love.graphics.push()
--   love.graphics.translate(400-1024+mapX,300-1024+mapY)
--   atlMap2:draw()
--   love.graphics.pop()

   love.graphics.draw( image,
		       SCR_CENTER_X - image:getWidth()/2,
		       SCR_CENTER_Y - image:getHeight() )

   love.graphics.push()
   love.graphics.setLine( 1, "rough" )
   love.graphics.setColor( 0, 255, 0 )
   love.graphics.translate( SCR_CENTER_X - 16 + player_offX - TILESIZE*player_tileX,
			    SCR_CENTER_Y - 16 + player_offY - TILESIZE*player_tileY )
   love.graphics.rectangle( "line", TILESIZE*player_tileX, TILESIZE*player_tileY,
			    TILESIZE, TILESIZE )
   love.graphics.setColor( 0, 255, 0 )
   love.graphics.rectangle( "line", TILESIZE * sel_tileX, TILESIZE * sel_tileY,
			    TILESIZE, TILESIZE )
   love.graphics.pop()

   love.graphics.setColor( 255, 0, 0 )
   love.graphics.line( SCR_CENTER_X - 5, SCR_CENTER_Y,
		       SCR_CENTER_X + 5, SCR_CENTER_Y )
   love.graphics.line( SCR_CENTER_X, SCR_CENTER_Y - 5,
		       SCR_CENTER_X, SCR_CENTER_Y + 5 )

end

-- -----------------------------------------------------------------------------
function love.keyreleased( key )
   if key == "escape" then
      love.event.push( "quit" )
   end
   if key == "d" then
      print( atlMap1:getDrawRange() )
   end
end

-- -----------------------------------------------------------------------------
function love.mousereleased( x, y, button )
   if button == "l" then
      local local_x = x - SCR_CENTER_X + 16 - player_offX
      local local_y = y - SCR_CENTER_Y + 16 - player_offY
      sel_tileX = player_tileX + math.floor( local_x / TILESIZE )
      sel_tileY = player_tileY + math.floor( local_y / TILESIZE )
   end
end

-- -----------------------------------------------------------------------------
