-- -----------------------------------------------------------------------------
local AStar = {}

-- -----------------------------------------------------------------------------
function AStar:solve( start, goal, world )
   AStar.world = world
   local closedset = {}
   local openset = {start}
   local came_from = AStar.came_from
   local g_score = AStar.g_score
   local f_score = AStar.f_score

   came_from[start.x][start.y] = nil
   g_score[start.x][start.y] = 0
   f_score[start.x][start.y] = AStar._hce( start, goal )

   while( #openset > 0 )do
      local current = openset[1]
      local f_current = f_score[current.x][current.y]
      local i_current = 1
      for i, v in ipairs(openset) do
	 local f_v = f_score[v.x][v.y]
	 if f_v < f_current then
	    current = v
	    f_current = f_v
	    i_current = i
	 end
      end

      if AStar.sameNode( current, goal ) then
	 return AStar.reconstruct( goal )
      end

      table.remove( openset, i_current )
      table.insert( closedset, current )

      if #closedset > 200 then
	 return nil
      end

      for _, neigh in ipairs( AStar.neighbors( current ) ) do
	 if not AStar.nodeInSet( neigh, closedset ) then
	    local new_g_score = g_score[current.x][current.y] + 1
	    if AStar.nodeInSet( neigh, openset ) then
	       if new_g_score < g_score[neigh.x][neigh.y] then
		  came_from[neigh.x][neigh.y] = current
		  g_score[neigh.x][neigh.y] = new_g_score
		  f_score[neigh.x][neigh.y] = new_g_score + AStar._hce( neigh, goal )
	       end
	    else
	       table.insert( openset, neigh )
	       came_from[neigh.x][neigh.y] = current
	       g_score[neigh.x][neigh.y] = new_g_score
	       f_score[neigh.x][neigh.y] = new_g_score + AStar._hce( neigh, goal )
	    end
	 end
      end
   end

   return nil
end

-- -----------------------------------------------------------------------------
function AStar.emptyMap()
   local mm = {}

   for i = -32, 63 do
      mm[i] = {}
   end

   return mm
end

-- -----------------------------------------------------------------------------
function AStar._hce( start, goal )
   local dx = goal.x - start.x
   local dy = goal.y - start.y
   return dx*dx + dy*dy
end

-- -----------------------------------------------------------------------------
function AStar.sameNode( a, b )
   return (a.x == b.x) and (a.y == b.y)
end

-- -----------------------------------------------------------------------------
function AStar.nodeInSet( node, set )
   for _,v in pairs( set ) do
      if AStar.sameNode( v, node ) then
	 return true
      end
   end
   return false
end

-- -----------------------------------------------------------------------------
function AStar.neighbors( current )
   local nn = {}

   if current.x > -32 then
      if AStar.world:isWalkable( current.x-1, current.y ) then
	 table.insert( nn, {x=current.x-1,y=current.y} )
      end
   end
   if current.x < 63 then
      if AStar.world:isWalkable( current.x+1, current.y ) then
	 table.insert( nn, {x=current.x+1,y=current.y} )
      end
   end
   if current.y > -32 then
      if AStar.world:isWalkable( current.x, current.y-1 ) then
	 table.insert( nn, {x=current.x,y=current.y-1} )
      end
   end
   if current.y < 63 then
      if AStar.world:isWalkable( current.x, current.y+1 ) then
	 table.insert( nn, {x=current.x,y=current.y+1} )
      end
   end

   return nn
end

-- -----------------------------------------------------------------------------
function AStar.reconstruct( current )
   if AStar.came_from[current.x][current.y] then
      p = AStar.reconstruct( AStar.came_from[current.x][current.y] )
      table.insert( p, current )
      return p
   else
      return {current}
   end
end

-- -----------------------------------------------------------------------------
AStar.g_score = AStar.emptyMap()
AStar.f_score = AStar.emptyMap()
AStar.came_from = AStar.emptyMap()

-- -----------------------------------------------------------------------------
return AStar

-- -----------------------------------------------------------------------------
