-- -----------------------------------------------------------------------------
local ATL = require("AdvTiledLoader")

-- -----------------------------------------------------------------------------
-- Define path so lua knows where to look for files.
GAMEPLAY_LOADER_PATH = GAMEPLAY_LOADER_PATH or ({...})[1]:gsub("[%.\\/][Ww]orld$", "") .. '.'

local UTIL = require("Util")

local printInfo = UTIL.Debug.printInfo
local printWarning = UTIL.Debug.printWarning

-- -----------------------------------------------------------------------------
local World = {}
World.__index = World

local TILESIZE = 32
local CHUNKSIZE = 1024
local CHUNKTILES = 32
local CHUNKNAME = "chunk%02X%02X.tmx"
local SCR_WIDTH = love.graphics:getWidth()
local SCR_HEIGHT = love.graphics:getHeight()
local SCR_MID_WIDTH = SCR_WIDTH/2
local SCR_MID_HEIGHT = SCR_HEIGHT/2
local START_X = SCR_MID_WIDTH - TILESIZE/2 - 2*CHUNKSIZE
local START_Y = SCR_MID_HEIGHT - TILESIZE/2 - 2*CHUNKSIZE

-- -----------------------------------------------------------------------------
-- Returns a new World
function World:new()
   local world = {}
   setmetatable(world, World)

   -- Public:
   world.subworld = {{nil,nil,nil},
		     {nil,nil,nil},
		     {nil,nil,nil}}

   world.wtx = 100
   world.wty = 99
   world:loadChunks( world.wtx, world.wty )

   -- Private:

   return world
end

-- -----------------------------------------------------------------------------
function World:newPlayer( name, type, x, y, w, h )
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
   self.wtx = self.wtx - 1
   for j = 1,3 do
      self.subworld[3][j] = self.subworld[2][j]
      self.subworld[2][j] = self.subworld[1][j]
      self.subworld[1][j] = self:loadChunk( self.wtx - 1, self.wty + j - 2 )
   end
   printInfo( "world moved to: ", self.wtx, self.wty )
end

-- -----------------------------------------------------------------------------
function World:moveRight()
   self.wtx = self.wtx + 1
   for j = 1,3 do
      self.subworld[1][j] = self.subworld[2][j]
      self.subworld[2][j] = self.subworld[3][j]
      self.subworld[3][j] = self:loadChunk( self.wtx + 1, self.wty + j - 2 )
   end
   printInfo( "world moved to: ", self.wtx, self.wty )
end

-- -----------------------------------------------------------------------------
function World:moveUp()
   self.wty = self.wty - 1
   for i = 1,3 do
      self.subworld[i][3] = self.subworld[i][2]
      self.subworld[i][2] = self.subworld[i][1]
      self.subworld[i][1] = self:loadChunk( self.wtx + i - 2, self.wty - 1 )
   end
   printInfo( "world moved to: ", self.wtx, self.wty )
end

-- -----------------------------------------------------------------------------
function World:moveDown()
   self.wty = self.wty + 1
   for i = 1,3 do
      self.subworld[i][1] = self.subworld[i][2]
      self.subworld[i][2] = self.subworld[i][3]
      self.subworld[i][3] = self:loadChunk( self.wtx + i - 2, self.wty + 1 )
   end
   printInfo( "world moved to: ", self.wtx, self.wty )
end

-- -----------------------------------------------------------------------------
function World:loadChunks( wtx, wty )
   for j = 1,3 do
      for i = 1,3 do
	 self.subworld[i][j] = self:loadChunk( wtx + i - 2, wty + j - 2 )
      end
   end
end

-- -----------------------------------------------------------------------------
function World:loadChunk( wtx, wty )
   local filename = string.format( CHUNKNAME, wtx, wty)
   local chunk = nil
   if ATL.Loader.exists( filename ) then
      chunk = World._loadMap( filename )
      printInfo( filename, "loaded" )
   else
      printWarning( filename, "not found" )
   end
   return chunk
end

-- -----------------------------------------------------------------------------
function World:updateInOut( tx, ty )
   local mapr = self.subworld[2]
   local map = mapr and mapr[2] or nil
   if map and tx >= 0 and tx <= 31 and ty >= 0 and ty <= 31 then
      local intLayer = map.tl["int"]
      local ceilLayer = map.tl["ceil"]
      local extLayer = map.tl["ext"]
      local inside = false
      if intLayer then
	 inside = nil ~= intLayer.tileData( tx, ty )
      end

      if intLayer then
	 intLayer.opacity = inside and 1 or 0
      end
      if extLayer then
	 extLayer.opacity = inside and 0 or 1
      end
      if ceilLayer then
	 ceilLayer.opacity = inside and 0 or 1
      end
   end
end

-- -----------------------------------------------------------------------------
function World:setCollisionVisible( val )
   for j = 1,3 do
      for i = 1,3 do
	 local map = self.subworld[i][j]
	 if map and map.tl["collision"] then
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

   if map.tl["int"] then
      map.tl["int"].opacity = 0
   end

   return map
end

-- -----------------------------------------------------------------------------
return World

-- -----------------------------------------------------------------------------
