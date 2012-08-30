GAMEPLAY_PATH = GAMEPLAY_PATH or ({...})[1]:gsub("[%.\\/]init$", "") .. '.'

-- Return the classes in a table
return {
   Player = require(GAMEPLAY_PATH  .. "Player")
}
