-- -----------------------------------------------------------------------------
local ATL = require("AdvTiledLoader")

-- -----------------------------------------------------------------------------
local World = {}
World.__index = World

local TILESIZE = 32
local SCR_CENTER_X
local SCR_CENTER_Y

-- -----------------------------------------------------------------------------
-- Returns a new World
function World:new()
   local world = {}
   setmetatable(world, World)

   SCR_CENTER_X = love.graphics:getWidth()/2
   SCR_CENTER_Y = love.graphics:getHeight()/2

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
   love.graphics.setColor( 255, 255, 255 )
   love.graphics.push()
   love.graphics.translate(
      SCR_CENTER_X - 16 - 1024 - player.offx - TILESIZE*player.tilex,
      SCR_CENTER_Y - 16 - 1024 - player.offy - TILESIZE*player.tiley )
   for j = 1,3 do
      for i = 1,3 do
	 if self.subworld[i][j] then
	    love.graphics.push()
	    love.graphics.translate( 1024*(i-1), 1024*(j-1) )
	    self.subworld[i][j]:draw()
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
   local mapi = math.floor((x + 32) / 32) + 1
   local mapj = math.floor((y + 32) / 32) + 1

   local mapr = self.subworld[mapi]
   local map = mapr and mapr[mapj] or nil

   if map then
      local collisionLayer = map.tl["collision"]
      if collisionLayer then
	 local rx = x - (32*(mapi-2))
	 local ry = y - (32*(mapj-2))
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
