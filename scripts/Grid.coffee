define ['Crafty', 'Square'], (Crafty, Square) ->

	OFFSET = 100
	GUTTER = 10
	SQSIZE = 50
	COLS = 5
	ROWS = 5

	UP = 0
	RIGHT = 1
	DOWN = 2
	LEFT = 3
	LIMIT = 4

	HORIZ = (dir) -> !!(dir%2)

	END = (dn, n, low, high) ->
		return n unless dn
		return high if dn > 0
		return low

	COL_END = (dx, x) -> END(dx, x, 0, COLS)
	ROW_END = (dy, y) -> END(dy, y, 0, ROWS)

	GRIDLOC = (n) -> n*(SQSIZE+GUTTER) + OFFSET

	class Grid
		constructor: () ->
			@_grid = []
			for col in [0..(COLS-1)]
				@_grid[col] = []
				for row in [0..(ROWS-1)]
					@newSquareAt(col, row, yes)

		newSquareAt: (x, y, preventMatching) ->
			e = Crafty.e(Square).shift(GRIDLOC(x), GRIDLOC(y))
			e.gridX = x
			e.gridY = y
			@_grid[x][y] = e

			e.randomizeDirection()
			if preventMatching
				while @matching(e) then e.randomizeDirection()

			e.bind('RotateEnd', @checkConditions)
			e.bind('ExplodeEnd', @removeAndReplace)

		getSquareAt: (x, y) -> @_grid[x]?[y]

		matching: (e) ->
			dir = e.getDirection()

			{gridX, gridY} = e

			switch dir
				when UP then gridY -= 1
				when DOWN then gridY += 1
				when LEFT then gridX -= 1
				when RIGHT then gridX += 1


			toCheck = @getSquareAt(gridX, gridY)
			return unless toCheck?
			checkDir = toCheck.getDirection()

			matching = switch dir
				when UP then checkDir is DOWN
				when DOWN then checkDir is UP
				when LEFT then checkDir is RIGHT
				when RIGHT then checkDir is LEFT

			if matching then return toCheck

		checkConditions: (e) =>
			toCheck = @matching(e)
			if toCheck?
				e.explode()
				toCheck.explode()

		removeAndReplace: (e) =>
			{gridX, gridY} = e

			switch e.getDirection()
				when UP then @shiftStartingAt(gridX, gridY, 0, -1)
				when DOWN then @shiftStartingAt(gridX, gridY, 0, 1)
				when LEFT then @shiftStartingAt(gridX, gridY, -1, 0)
				when RIGHT then @shiftStartingAt(gridX, gridY, 1, 0)

			return

		shiftStartingAt: (x, y, dx, dy) ->
			for col in [(x-dx)..COL_END(-dx, x)]
				for row in [(y-dy)..ROW_END(-dy, y)]
					@moveWithinGrid(@getSquareAt(col, row), dx, dy)
			return

		moveWithinGrid: (e, dx, dy) ->
			return unless e? and not e.hasExploded()
			e.gridX += dx
			e.gridY += dy
			e.moveTo(GRIDLOC(e.gridX), GRIDLOC(e.gridY))

	return Grid