-- -----------------------------------------------------------------------------
local Debug = {}
Debug.__index = Debug

-- -----------------------------------------------------------------------------
Debug.enabled = false

-- -----------------------------------------------------------------------------
function Debug.drawCross( x, y )
   love.graphics.line( x - 5, y, x + 5, y )
   love.graphics.line( x, y - 5, x, y + 5 )
end

-- -----------------------------------------------------------------------------
return Debug

-- -----------------------------------------------------------------------------
