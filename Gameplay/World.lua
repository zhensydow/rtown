-- -----------------------------------------------------------------------------
local ATL = require("AdvTiledLoader")

-- -----------------------------------------------------------------------------
local World = {}
World.__index = World

local TILESIZE = 32
local CHUNKSIZE = 1024
local SCR_WIDTH
local SCR_HEIGHT
local SCR_MID_WIDTH
local SCR_MID_HEIGHT
local START_X
local START_Y

-- -----------------------------------------------------------------------------
-- Returns a new World
function World:new()
   local world = {}
   setmetatable(world, World)

   SCR_WIDTH = love.graphics:getWidth()
   SCR_HEIGHT = love.graphics:getHeight()
   SCR_MID_WIDTH = SCR_WIDTH/2
   SCR_MID_HEIGHT = SCR_HEIGHT/2
   START_X = SCR_MID_WIDTH - TILESIZE/2 - 2*CHUNKSIZE
   START_Y = SCR_MID_HEIGHT - TILESIZE/2 - 2*CHUNKSIZE

   -- Public:
   world.subworld = {{nil,nil,nil},
		     {nil,nil,nil},
		     {nil,nil,nil}}

   world:loadChunk( 100, 100 )

   -- Private:

   return world
end

-- -----------------------------------------------------------------------------
function World:newObject( name, type, x, y, w, h )
   return self.subworld[2][2].ol["player"]:newObject(
      name, type, x, y, w, h )
end

-- -----------------------------------------------------------------------------
function World:draw()
   local player = self.player
   local playerx = TILESIZE*player.tilex + player.offx
   local playery = TILESIZE*player.tiley + player.offy
   love.graphics.setColor( 255, 255, 255 )
   love.graphics.push()
   love.graphics.translate(
      START_X - TILESIZE*player.tilex - player.offx,
      START_Y - TILESIZE*player.tiley - player.offy )
   for j = 1,3 do
      for i = 1,3 do
	 local chunk = self.subworld[i][j]
	 if chunk then
	    love.graphics.push()
	    love.graphics.translate( CHUNKSIZE*i, CHUNKSIZE*j )
	    local rx = player.tilex - (TILESIZE*(i-2))
	    local ry = player.tiley - (TILESIZE*(j-2))
	    chunk:setDrawRange(
	       TILESIZE*rx + player.offx - SCR_MID_WIDTH,
	       TILESIZE*ry + player.offy - SCR_MID_HEIGHT,
	       SCR_WIDTH, SCR_HEIGHT)
	    chunk:draw()
	    love.graphics.pop()
	 end
      end
   end
   love.graphics.pop()
end

-- -----------------------------------------------------------------------------
function World:isBlocked( x, y )
   return not self:isWalkable( x, y )
end

-- -----------------------------------------------------------------------------
function World:isWalkable( x, y )
   local mapi = math.floor((x + TILESIZE) / TILESIZE) + 1
   local mapj = math.floor((y + TILESIZE) / TILESIZE) + 1

   local mapr = self.subworld[mapi]
   local map = mapr and mapr[mapj] or nil

   if map then
      local collisionLayer = map.tl["collision"]
      if collisionLayer then
	 local rx = x - (TILESIZE*(mapi-2))
	 local ry = y - (TILESIZE*(mapj-2))
	 return not collisionLayer.tileData(rx,ry)
      else
	 return true
      end
   end

   return false
end

-- -----------------------------------------------------------------------------
function World:loadChunk( wtx, wty )
   for j = 1,3 do
      for i = 1,3 do
	 local filename = string.format(
	    "chunk%02X%02X.tmx",  wtx + i - 2, wty + j - 2)
	 self.subworld[i][j] = World._loadMap( filename )
      end
   end
end

-- -----------------------------------------------------------------------------
function World._loadMap( name )
   local map

   map = ATL.Loader.load( name )

   if map.tl["collision"] then
--      map.tl["collision"].opacity = 0
   end

   return map
end

-- -----------------------------------------------------------------------------
return World

-- -----------------------------------------------------------------------------
