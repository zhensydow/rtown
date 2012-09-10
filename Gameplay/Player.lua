-- -----------------------------------------------------------------------------
local Player = {}
Player.__index = Player

-- -----------------------------------------------------------------------------
-- Define path so lua knows where to look for files.
GAMEPLAY_LOADER_PATH = GAMEPLAY_LOADER_PATH or ({...})[1]:gsub("[%.\\/][Pp]layer$", "") .. '.'

local AnimManager = require(GAMEPLAY_LOADER_PATH .. "AnimManager")

-- -----------------------------------------------------------------------------
-- Returns a new Player
function Player:new( world )
   local player = {}
   setmetatable(player, Player)

   -- Public:
   player.offx = 0
   player.offy = 0
   player.path = nil

   -- Private:
   player.brush = world:newObject( "Player", "Entity", 0, 0, 64, 64 )
   player.brush.quads = {
      up = love.graphics.newQuad(0,0,64,64,576,256),
      left = love.graphics.newQuad(0,64,64,64,576,256),
      down = love.graphics.newQuad(0,128,64,64,576,256),
      right = love.graphics.newQuad(0,192,64,64,576,256)
   }

   local quads = player.brush.quads
   for i = 0,8 do
      quads["up"..i] = love.graphics.newQuad((i+1)*64,0,64,64,576,256)
      quads["left"..i] = love.graphics.newQuad((i+1)*64,64,64,64,576,256)
      quads["down"..i] = love.graphics.newQuad((i+1)*64,128,64,64,576,256)
      quads["right"..i] = love.graphics.newQuad((i+1)*64,192,64,64,576,256)
   end

   player.brush.image = love.graphics.newImage( "gfx/walkcycle.png" )
   player.brush.width = player.brush.image:getWidth()
   player.brush.height = player.brush.image:getHeight()

   player:setStop( "left" )

   player.brush.draw = function ()
			  local brush = player.brush
			  love.graphics.drawq(
			     brush.image,
			     brush.quads[brush.sprite],
			     brush.x + player.offx, brush.y + player.offy )
		       end

   player:setTile( 1, 1 )
   AnimManager.addEntity( player )

   return player
end

-- -----------------------------------------------------------------------------
function Player:updateAnim()
   local brush = self.brush
   if not brush.static then
      local nextAnim = brush.anim + 1
      if (nextAnim >= 8) and (not brush.repeatAnim) then
	 brush.static = true
      else
	 brush.anim = nextAnim % 8
      end
      
      brush.sprite = brush.facing .. brush.anim
   end
end

-- -----------------------------------------------------------------------------
function Player:update( dt )
   local mvAmount = dt * 48
   while mvAmount > 0 do
      if self:inTile() then
	 if self:hasPath() then
	    self:updateTile()
	 else
	    self:setStop( self.brush.facing )
	    mvAmount = 0
	 end
      else
	 local newfacing
	 if math.abs( self.offx ) > math.abs( self.offy ) then
	    newfacing = (self.offx < 0) and "right" or "left"
	 else
	    newfacing = (self.offy < 0) and "down" or "up"
	 end
	 if self.brush.static or newfacing ~= self.brush.facing then
	    self:setMove( newfacing )
	 end
	 local moved = self:moveToTile( mvAmount )
	 mvAmount = mvAmount - moved
      end
   end
end

-- -----------------------------------------------------------------------------
function Player:inTile()
   local checkx = math.abs( self.offx ) < 0.001
   local checky = math.abs( self.offy ) < 0.001
   return checkx and checky
end

-- -----------------------------------------------------------------------------
function Player:hasPath()
   if self.path and #self.path > 0 then
      local newTile = self.path[1]
      print( self.tilex, self.tiley, "->", newTile.x, newTile.y )
      table.remove(self.path, 1)
      if newTile.x ~= self.tilex or newTile.y ~= self.tiley then
	 local newoffx = -(newTile.x - self.tilex) * 32
	 local newoffy = -(newTile.y - self.tiley) * 32
	 self:setTile( newTile.x, newTile.y )
	 self.offx = newoffx
	 self.offy = newoffy
      end
   end
   return false
end

-- -----------------------------------------------------------------------------
function Player:moveToTile( amount )
   local doff = math.sqrt(self.offx*self.offx + self.offy*self.offy)
   local total = math.min( amount, doff )
   self.offx = self.offx - (total * self.offx / doff)
   self.offy = self.offy - (total * self.offy / doff)
   return total
end

-- -----------------------------------------------------------------------------
function Player:setStop( facing )
   self.brush.facing = facing
   self.brush.anim = 0
   self.brush.sprite = facing
   self.brush.static = true
   self.brush.repeatAnim = false
end

-- -----------------------------------------------------------------------------
function Player:setMove( facing )
   self.brush.facing = facing
   self.brush.anim = 0
   self.brush.sprite = self.brush.facing .. self.brush.anim
   self.brush.static = false
   self.brush.repeatAnim = false
end

-- -----------------------------------------------------------------------------
function Player:setTile( tx, ty )
   local x = tx * 32 + 16
   local y = tx * 32 - 8
   self.tilex = tx
   self.tiley = ty
   self.offx = 0
   self.offy = 0
   self.brush:moveTo( x, y )
end

-- -----------------------------------------------------------------------------
-- Return the Player class
return Player

-- -----------------------------------------------------------------------------
