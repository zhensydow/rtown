-- -----------------------------------------------------------------------------
local Debug = {}
Debug.__index = Debug

-- -----------------------------------------------------------------------------
Debug.enabled = false
Debug.info = false
Debug.warning = false
Debug.layer = {false,false,false,false,false,false}

-- -----------------------------------------------------------------------------
function Debug.printInfo( ... )
   if Debug.info then
      print( "INF: ", unpack( arg ) )
   end
end

-- -----------------------------------------------------------------------------
function Debug.printWarning( ... )
   if Debug.warning then
      print( "WAR: ", unpack( arg ) )
   end
end

-- -----------------------------------------------------------------------------
function Debug.printError( ... )
   print( "ERR: ", unpack( arg ) )
end

-- -----------------------------------------------------------------------------
function Debug.drawCross( x, y )
   love.graphics.line( x - 5, y, x + 5, y )
   love.graphics.line( x, y - 5, x, y + 5 )
end

-- -----------------------------------------------------------------------------
return Debug

-- -----------------------------------------------------------------------------
