UTIL_PATH = UTIL_PATH or ({...})[1]:gsub("[%.\\/]init$", "") .. '.'

-- Return the classes in a table
return {
   AStar = require(UTIL_PATH  .. "AStar")
}
