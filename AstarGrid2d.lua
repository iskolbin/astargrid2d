local floor, huge, abs, max = math.floor, math.huge, math.abs, math.max

local AstarGrid2d = {
	-- Heuristics
	DIJKSTRA = function() return 0 end,
	MANHATTAN = function( dx, dy ) return abs( dx ) + abs( dy ) end,
	EUCLIDEAN = function( dx, dy ) return ( dx*dx + dy*dy )^0.5 end,
	CHEBYSHEV = function( dx, dy ) return max( abs( dx ), abs( dy )) end,


	-- Successors
	-- Diagonal neighbors is never reachable
	ORTHO = function( grid, cost, x, y, t )
		local n = 1
		if cost( grid,  x , y-1 ) ~= huge then t[ 1 ], t[ 2 ], t[ 3 ], n =  x , y-1, false,  4  end
		if cost( grid,  x , y+1 ) ~= huge then t[ n ], t[n+1], t[n+2], n =  x , y+1, false, n+3 end
		if cost( grid, x-1,  y  ) ~= huge then t[ n ], t[n+1], t[n+2], n = x-1,  y , false, n+3 end
		if cost( grid, x+1,  y  ) ~= huge then t[ n ], t[n+1], t[n+2], n = x+1,  y , false, n+3 end
		return t, n-1
	end,
	
	-- Diagonal neighbors always reachable
	DIAG0 = function( grid, cost, x, y, t )	
		local n = 1
		if cost( grid,  x , y-1 ) ~= huge then t[ 1 ], t[ 2 ], t[ 3 ], n =  x , y-1, false,  4  end
		if cost( grid,  x , y+1 ) ~= huge then t[ n ], t[n+1], t[n+2], n =  x , y+1, false, n+3 end
		if cost( grid, x-1,  y  ) ~= huge then t[ n ], t[n+1], t[n+2], n = x-1,  y , false, n+3 end
		if cost( grid, x+1,  y  ) ~= huge then t[ n ], t[n+1], t[n+2], n = x+1,  y , false, n+3 end
		if cost( grid, x+1, y+1, true ) ~= huge then t[n], t[n+1], t[n+2], n = x+1, y+1, true, n+3 end
		if cost( grid, x-1, y+1, true ) ~= huge then t[n], t[n+1], t[n+2], n = x-1, y+1, true, n+3 end
		if cost( grid, x+1, y-1, true ) ~= huge then t[n], t[n+1], t[n+2], n = x+1, y-1, true, n+3 end
		if cost( grid, x-1, y-1, true ) ~= huge then t[n], t[n+1], t[n+2], n = x-1, y-1, true, n+3 end
		return t, n-1
	end,

	-- Diagonal neighbors reachable only when at least 1 of the orthogonal neighbors has not infinite cost
	DIAG1 = function( grid, cost, x, y, t )	
		local n = 1
		local costy_1 = cost( grid,  x , y-1 ) ~= huge
		local costx_1 = cost( grid, x-1,  y  ) ~= huge
		local costxp1 = cost( grid, x+1,  y  ) ~= huge
		local costyp1 = cost( grid,  x , y+1 ) ~= huge
		if costy_1 then t[ 1 ], t[ 2 ], t[ 3 ], n =  x , y-1, false,  4  end
		if costyp1 then t[ n ], t[n+1], t[n+2], n =  x , y+1, false, n+3 end
		if costx_1 then t[ n ], t[n+1], t[n+2], n = x-1,  y , false, n+3 end
		if costxp1 then t[ n ], t[n+1], t[n+2], n = x+1,  y , false, n+3 end
		if cost( grid, x+1, y+1, true ) ~= huge and (costxp1 or costyp1) then t[n], t[n+1], t[n+2], n = x+1, y+1, true, n+3 end
		if cost( grid, x-1, y+1, true ) ~= huge and (costx_1 or costyp1) then t[n], t[n+1], t[n+2], n = x-1, y+1, true, n+3 end
		if cost( grid, x+1, y-1, true ) ~= huge and (costxp1 or costy_1) then t[n], t[n+1], t[n+2], n = x+1, y-1, true, n+3 end
		if cost( grid, x-1, y-1, true ) ~= huge and (costx_1 or costy_1) then t[n], t[n+1], t[n+2], n = x-1, y-1, true, n+3 end
		return t, n-1
	end,
	
	-- Diagonal neighbors reachable only when both orthogonal neighbors have not infinite cost
	DIAG2 = function( grid, x, y, t )	
		local n = 1
		local costy_1 = cost( grid,  x , y-1 ) ~= huge
		local costx_1 = cost( grid, x-1,  y  ) ~= huge
		local costxp1 = cost( grid, x+1,  y  ) ~= huge
		local costyp1 = cost( grid,  x , y+1 ) ~= huge
		if costy_1 then t[ 1 ], t[ 2 ], t[ 3 ], n =  x , y-1, false,  4  end
		if costyp1 then t[ n ], t[n+1], t[n+2], n =  x , y+1, false, n+3 end
		if costx_1 then t[ n ], t[n+1], t[n+2], n = x-1,  y , false, n+3 end
		if costxp1 then t[ n ], t[n+1], t[n+2], n = x+1,  y , false, n+3 end
		if cost( grid, x+1, y+1, true ) ~= huge and costxp1 and costyp1 then t[n], t[n+1], t[n+2], n = x+1, y+1, true, n+3 end
		if cost( grid, x-1, y+1, true ) ~= huge and costx_1 and costyp1 then t[n], t[n+1], t[n+2], n = x-1, y+1, true, n+3 end
		if cost( grid, x+1, y-1, true ) ~= huge and costxp1 and costy_1 then t[n], t[n+1], t[n+2], n = x+1, y-1, true, n+3 end
		if cost( grid, x-1, y-1, true ) ~= huge and costx_1 and costy_1 then t[n], t[n+1], t[n+2], n = x-1, y-1, true, n+3 end
		return t, n-1
	end,


	-- Typical cost functions when costs stored directly into grid
	COSTCHEBYSHEV = function( grid, x, y ) return grid[x][y] end,
	
	COSTMANHATTAN = function( grid, x, y, diag ) 
		if diag then
			return 2*grid[x][y]
		else
			return grid[x][y]
		end
	end,
	
	COSTEUCLIDEAN = function( grid, x, y, diag ) 
		if diag then
			return 1.4142135623731*grid[x][y]
		else
			return grid[x][y]
		end
	end,
}

function AstarGrid2d.findpath( grid, heuristics, successors, cost, x0, y0, x1, y1 )
	local close = {}
	local dx, dy = x1, y1
	local start = { 0, heuristics( dx, dy ), false, x1, y1, }
	local open, n = {start}, 1
	local topush = {}
	local resultcoords, resultn = {}, 0

	while n > 0 do
		-- Dequeue from open
		local current = open[1]
		local size = n

		open[1] = open[size]
		open[size] = nil
		size = size - 1
		n = size

		local index, leftIndex, rightIndex = 1, 2, 3
		while leftIndex <= size do
			local smallerChild = leftIndex
			if rightIndex <= size and open[leftIndex][2] > open[rightIndex][2] then
				smallerChild = rightIndex
			end

			if open[index][2] > open[smallerChild][2] then
				open[index], open[smallerChild] = open[smallerChild], open[index]
			else
				break
			end

			index = smallerChild
			leftIndex = index + index
			rightIndex = leftIndex + 1
		end
		
		local x, y = current[4], current[5]

 		-- Reached goal node
		if x == x0 and y == y0 then
			local pred
			return function()
				if current then
					pred = current
					current = current[3]
					return pred[4], pred[5]
				end
			end
		end

		close[x] = close[x] or {}
		close[x][y] = current
		local g = current[1]

		local count = 0

		-- Examine successors
		resultcoords, resultn = successors( grid, cost, x, y, resultcoords )
		for i = 1, resultn, 3 do
			local x_, y_, diag = resultcoords[i], resultcoords[i+1], resultcoords[i+2]
			local g_ = g + cost( grid, x, y, diag )

			if g_ ~= huge then
				local next_ = close[x_] and close[x_][y_]
				local dx, dy = x0 - x_, y0 - y_
				if not next_ then
					count = count + 1
					topush[count] = { g_, g_ + heuristics( dx, dy ), current, x_, y_, }
				elseif g_ < next_[1] then
					next_[1], next_[2], next_[3] = g_, g_ + heuristics( dx, dy ), current
					count = count + 1
					topush[count] = next_
				end
			end
		end

		-- Enqueue into open
		for i = 1, count do
			open[size + i] = topush[i]
		end

		size = n + count
		n = size

		for index_ = floor( 0.5 * size ), 1, -1 do
			local index = index_
			local leftIndex = index + index
			local rightIndex = leftIndex + 1
			while leftIndex <= size do
				local smallerChild = leftIndex
				if rightIndex <= size and open[leftIndex][2] > open[rightIndex][2] then
					smallerChild = rightIndex
				end

				if open[index][2] > open[smallerChild][2] then
					open[index], open[smallerChild] = open[smallerChild], open[index]
				else
					break
				end

				index = smallerChild
				leftIndex = index + index
				rightIndex = leftIndex + 1
			end
		end
	end
end


return AstarGrid2d
