local AStar = {}

function AStar:solve( start, goal )
   local closedset = {}
   local openset = {start}
   local came_from = AStar.came_from
   local g_score = AStar.g_score
   local f_score = AStar.f_score

   came_from[start.x][start.y] = nil
   g_score[start.x][start.y] = 0
   f_score[start.x][start.y] = AStar._hce( start, goal )

   while (#openset > 0) do
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
   
      if sameNode( current, goal ) then
         print( "found" )
         return AStar.reconstruct( goal )
      end

      table.remove( openset, i_current )
      table.insert( closedset, current )

      for _, neigh in ipairs( neighbors( current ) ) do
         if not nodeInSet( neigh, closedset ) then
            local new_g_score = g_score[current.x][current.y] + 1
            if nodeInSet( neigh, openset ) then
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

   print( "not found" )
   return nil
end

function emptyMap()
   local mm = {}

   for i = -32, 31 do
      mm[i] = {}
   end
   
   return mm
end

function AStar._hce( start, goal )
   local dx = goal.x - start.x
   local dy = goal.y - start.y
   return dx*dx + dy*dy
end

function sameNode( a, b )
   return (a.x == b.x) and (a.y == b.y)
end

function nodeInSet( node, set )
   for _,v in pairs( set ) do
      if sameNode( v, node ) then
         return true
      end
   end
   return false
end

function neighbors( current )
   local nn = {}

   if current.x > -32 then
      table.insert( nn, {x=current.x-1,y=current.y} )
   end
   if current.x < 31 then
      table.insert( nn, {x=current.x+1,y=current.y} )
   end
   if current.y > -32 then
      table.insert( nn, {x=current.x,y=current.y-1} )
   end
   if current.y < 31 then
      table.insert( nn, {x=current.x,y=current.y+1} )
   end

   return nn
end

function AStar.reconstruct( current )
   if AStar.came_from[current.x][current.y] then
      p = AStar.reconstruct( AStar.came_from[current.x][current.y] )
      table.insert( p, current )
      return p
   else
      return {current}
   end
end

AStar.g_score = emptyMap()
AStar.f_score = emptyMap()
AStar.came_from = emptyMap()

return AStar
