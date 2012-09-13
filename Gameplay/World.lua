-- -----------------------------------------------------------------------------
local ATL = require("AdvTiledLoader")

-- -----------------------------------------------------------------------------
local World = {}
World.__index = World

-- -----------------------------------------------------------------------------
-- Returns a new World
function World:new()
   local world = {}

   -- Public:
   world.subworld = {{nil,nil,nil},
		     {nil,nil,nil},
		     {nil,nil,nil}}

   world.subworld[2][2] = World._loadMap("chunk01.tmx")

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
   self.subworld[2][2]:draw()
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
