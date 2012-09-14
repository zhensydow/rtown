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

   SCR_CENTER_X = love.graphics:getWidth()/2
   SCR_CENTER_Y = love.graphics:getHeight()/2

   -- Public:
   world.subworld = {{nil,nil,nil},
		     {nil,nil,nil},
		     {nil,nil,nil}}

   world.subworld[2][2] = World._loadMap("chunk6464.tmx")

   -- Private:

   return setmetatable(world, World)
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
      SCR_CENTER_X - 16 - player.offx - TILESIZE*player.tilex,
      SCR_CENTER_Y - 16 - player.offy - TILESIZE*player.tiley )
   self.subworld[2][2]:draw()
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

   local map = self.subworld[mapi][mapj]

   if map then
      local collisionLayer = map.tl["collision"]
      if collisionLayer then
	 return not collisionLayer.tileData(x+1,y+1)
      else
	 return true
      end
   end

   return false
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
