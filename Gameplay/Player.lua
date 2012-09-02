-- -----------------------------------------------------------------------------
local Player = {}
Player.__index = Player

-- -----------------------------------------------------------------------------
-- Returns a new Player
function Player:new( world )
   local player = {}
   setmetatable(player, Player)

   -- Public:

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

   player:setStop( "up" )

   player.brush.draw = function ()
			  local brush = player.brush
			  love.graphics.drawq(
			     brush.image,
			     brush.quads[brush.sprite],
			     brush.x, brush.y )
		       end

   return player
end

-- -----------------------------------------------------------------------------
function Player:updateAnim( facing )
   local brush = self.brush
   if facing ~= brush.facing then
      brush.facing = facing
      brush.anim = 0
   else
      brush.anim = (brush.anim + 1) % 8
   end
   brush.sprite = brush.facing .. brush.anim
end

-- -----------------------------------------------------------------------------
function Player:setStop( facing )
   self.brush.facing = facing
   self.brush.anim = 0
   self.brush.sprite = facing
end

-- -----------------------------------------------------------------------------
-- Return the Player class
return Player

-- -----------------------------------------------------------------------------
