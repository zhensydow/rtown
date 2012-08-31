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
function World:draw()
   self.subworld[2][2]:draw()
end

-- -----------------------------------------------------------------------------
function World:isBlocked( x, y )
   return not self:isWalkable( x, y )
end

-- -----------------------------------------------------------------------------
function World:isWalkable( x, y )
   local map = nil

   local mapi = math.floor((x + 32) / 32) + 1
   local mapj = math.floor((y + 32) / 32) + 1

   map = self.subworld[mapi][mapj]

   if map then
      return not map.tl["collision"].tileData(x+1,y+1)
   end

   return false
end

-- -----------------------------------------------------------------------------
function World._loadMap( name )
   local map

   map = ATL.Loader.load("chunk01.tmx")

   if map.tl["collision"] then
--      map.tl["collision"].opacity = 0
   end

   return map
end

-- -----------------------------------------------------------------------------
return World

-- -----------------------------------------------------------------------------
