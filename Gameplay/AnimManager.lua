-- -----------------------------------------------------------------------------
local AnimManager = {}
AnimManager.__index = AnimManager

-- -----------------------------------------------------------------------------
local TSTEP = 0.1
AnimManager.t_accum = 0
AnimManager.entities = {}

-- -----------------------------------------------------------------------------
function AnimManager.update( dt )
   local accum = AnimManager.t_accum + dt

   while accum >= TSTEP do
      accum = accum - TSTEP
      for i,k in pairs( AnimManager.entities ) do
	 k:updateAnim()
      end
   end
   AnimManager.t_accum = accum
end

-- -----------------------------------------------------------------------------
function AnimManager.addEntity( e )
   table.insert( AnimManager.entities, e )
end

-- -----------------------------------------------------------------------------
return AnimManager

-- -----------------------------------------------------------------------------
