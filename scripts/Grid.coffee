define ['Crafty', 'Square'], (Crafty, Square) ->

	OFFSET = 100
	GUTTER = 10
	SQSIZE = 50
	COLS = 5
	ROWS = 5

	GRIDLOC = (n) -> n*(SQSIZE+GUTTER) + OFFSET

	class Grid
		constructor: () ->
			@_grid = []
			for col in [0..(COLS-1)]
				@_grid[col] = []
				for row in [0..(ROWS-1)]
					@newSquareAt(col, row)

		newSquareAt: (x,y) ->
			e = Crafty.e(Square).anchorAt(GRIDLOC(x), GRIDLOC(y))
			e.randomizeDirection()
			@_grid[x][y] = e

	return Grid