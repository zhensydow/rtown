local Player = {}
Player.__index = Player


-- Returns a new Player
function Player:new()
   local player = {}

   -- Public:

   -- Private:
   player.image = love.graphics.newImage( "gfx/wizard.png" )

   return setmetatable(player, Player)
end


function Player:draw()
   love.graphics.draw( self.image, -self.image:getWidth()/2, -self.image:getHeight() )
end

-- Return the Player class
return Player
