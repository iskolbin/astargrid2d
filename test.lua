package.path=package.path..';../../util/grid2d/?.lua'

local Grid2d = require'Grid2d'
local AstarGrid2d = require'AstarGrid2d'

local x1, y1, x2, y2 = 0, 0, 0, 0
local grid = Grid2d.decode([[
####################
#.........#........#
#.........#........#
#.....###....##....#
#.......#....#.##..#
#.@.....#....#.!...#
#.......#....#.#...#
#.....###....###...#
#.........##...#...#
#.#........#.......#
####################]], function( grid, x, y, s ) 
	if s == '#' then
		return math.huge
	elseif s == '.' then
		return 1
	elseif s == '@' then
		x1, y1 = x, y
		return 1
	elseif s == '!' then
		x2, y2 = x, y
		return 1
	end
end )

for x, y in AstarGrid2d.findpath( grid, AstarGrid2d.EUCLIDEAN, AstarGrid2d.DIAG1, AstarGrid2d.COSTEUCLIDEAN, x1, y1, x2, y2 ) do
	grid[x][y] = -1
end

print( grid:encode( function( self, x, y, s )
	if s == math.huge then
		return '#'
	elseif x == x1 and y == y1 then
		return '@'
	elseif x == x2 and y == y2 then
		return '!'
	elseif s == -1 then
		return '.'
	else
		return ' '
	end
end))


