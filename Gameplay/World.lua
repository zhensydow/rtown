-- -----------------------------------------------------------------------------
local ATL = require("AdvTiledLoader")

-- -----------------------------------------------------------------------------
-- Define path so lua knows where to look for files.
GAMEPLAY_LOADER_PATH = GAMEPLAY_LOADER_PATH or ({...})[1]:gsub("[%.\\/][Ww]orld$", "") .. '.'

local UTIL = require("Util")

-- -----------------------------------------------------------------------------
local World = {}
World.__index = World

local TILESIZE = 32
local CHUNKSIZE = 1024
local CHUNKTILES = 32
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

   world:loadChunks( 100, 100 )

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
      START_X - TILESIZE*player.tilex - player.offx,
      START_Y - TILESIZE*player.tiley - player.offy )
   for j = 1,3 do
      for i = 1,3 do
	 local chunk = self.subworld[i][j]
	 if chunk then
	    love.graphics.push()
	    love.graphics.translate( CHUNKSIZE*i, CHUNKSIZE*j )
	    local rx = player.tilex - (CHUNKTILES*(i-2))
	    local ry = player.tiley - (CHUNKTILES*(j-2))
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
   local mapi = math.floor((x + CHUNKTILES) / CHUNKTILES) + 1
   local mapj = math.floor((y + CHUNKTILES) / CHUNKTILES) + 1

   local mapr = self.subworld[mapi]
   local map = mapr and mapr[mapj] or nil

   if map then
      local collisionLayer = map.tl["collision"]
      if collisionLayer then
	 local rx = x - (CHUNKTILES*(mapi-2))
	 local ry = y - (CHUNKTILES*(mapj-2))
	 return not collisionLayer.tileData(rx,ry)
      else
	 return true
      end
   end

   return false
end

-- -----------------------------------------------------------------------------
function World:moveLeft()
   for j = 1,3 do
      self.subworld[3][j] = self.subworld[2][j]
      self.subworld[2][j] = self.subworld[1][j]
      self.subworld[1][j] = nil
   end
end

-- -----------------------------------------------------------------------------
function World:moveRight()
   for j = 1,3 do
      self.subworld[1][j] = self.subworld[2][j]
      self.subworld[2][j] = self.subworld[3][j]
      self.subworld[3][j] = nil
   end
end

-- -----------------------------------------------------------------------------
function World:moveUp()
   for i = 1,3 do
      self.subworld[i][3] = self.subworld[i][2]
      self.subworld[i][2] = self.subworld[i][1]
      self.subworld[i][1] = nil
   end
end

-- -----------------------------------------------------------------------------
function World:moveDown()
   for i = 1,3 do
      self.subworld[i][1] = self.subworld[i][2]
      self.subworld[i][2] = self.subworld[i][3]
      self.subworld[i][3] = nil
   end
end

-- -----------------------------------------------------------------------------
function World:loadChunks( wtx, wty )
   for j = 1,3 do
      for i = 1,3 do
	 local filename = string.format(
	    "chunk%02X%02X.tmx",  wtx + i - 2, wty + j - 2)
	 self.subworld[i][j] = World._loadMap( filename )
      end
   end
end

-- -----------------------------------------------------------------------------
function World:setCollisionVisible( val )
   for j = 1,3 do
      for i = 1,3 do
	 local map = self.subworld[i][j]
	 if map.tl["collision"] then
	    map.tl["collision"].opacity = val and 1 or 0
	 end
      end
   end
end

-- -----------------------------------------------------------------------------
function World._loadMap( name )
   local map = ATL.Loader.load( name )

   if map.tl["collision"] then
      map.tl["collision"].opacity = UTIL.Debug.layer[1] and 1 or 0
   end

   return map
end

-- -----------------------------------------------------------------------------
return World

-- -----------------------------------------------------------------------------
