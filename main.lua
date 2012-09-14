-- -----------------------------------------------------------------------------
local ATL = require("AdvTiledLoader")
local GAME = require("Gameplay")
local UTIL = require("Util")
local AnimManager = GAME.AnimManager

-- -----------------------------------------------------------------------------
local TILESIZE = 32
local SCR_CENTER_X
local SCR_CENTER_Y

local sel_tileX = 0
local sel_tileY = 0

local m_player
local m_world

-- -----------------------------------------------------------------------------
function love.load()
   SCR_CENTER_X = love.graphics:getWidth()/2
   SCR_CENTER_Y = love.graphics:getHeight()/2

   ATL.Loader.path = 'gfx/maps/'

   m_world = GAME.World.new()
   m_player = GAME.Player:new( m_world )
   m_world.player = m_player
end

-- -----------------------------------------------------------------------------
function love.update( dt )
   AnimManager.update( dt )
   m_player:update( dt )
end

-- -----------------------------------------------------------------------------
function love.draw()
   m_world:draw()


   if UTIL.Debug.enabled then
      love.graphics.push()
      love.graphics.setLine( 1, "rough" )
      love.graphics.translate(
	 SCR_CENTER_X - 16 - m_player.offx - TILESIZE*m_player.tilex,
	 SCR_CENTER_Y - 16 - m_player.offy - TILESIZE*m_player.tiley )
      love.graphics.setColor( 50, 255, 50 )
      love.graphics.rectangle(
	 "line", TILESIZE*sel_tileX, TILESIZE*sel_tileY,
	 TILESIZE, TILESIZE )
      love.graphics.pop()

      love.graphics.setColor( 255, 0, 0 )
      UTIL.Debug.drawCross( SCR_CENTER_X, SCR_CENTER_Y )
      love.graphics.print("FPS "..tostring(love.timer.getFPS( )), 5, 5)
   end
end

-- -----------------------------------------------------------------------------
function love.keyreleased( key )
   if key == "escape" then
      love.event.push( "quit" )
   end
   -- Out debug info
   if key == "d" then
      UTIL.Debug.enabled = not UTIL.Debug.enabled
      -- print( atlMap1:getDrawRange() )
   end
end

-- -----------------------------------------------------------------------------
function love.mousereleased( x, y, button )
   if button == "l" then
      local local_x = x - SCR_CENTER_X + 16 + m_player.offx
      local local_y = y - SCR_CENTER_Y + 16 + m_player.offy
      sel_tileX = m_player.tilex + math.floor( local_x / TILESIZE )
      sel_tileY = m_player.tiley + math.floor( local_y / TILESIZE )
      blocked = m_world:isBlocked( sel_tileX, sel_tileY )
      if not blocked then
	 m_player.path  = UTIL.AStar:solve(
	    { x=m_player.tilex, y=m_player.tiley},
	    { x=sel_tileX, y=sel_tileY}, m_world )
      end
   end
end

-- -----------------------------------------------------------------------------
