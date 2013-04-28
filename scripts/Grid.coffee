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

	__DIRSTR__ = ["U","R","D","L"]

	HORIZ = (dir) -> !!(dir%2)

	TRUDIR = (dir) ->
		mod = dir%LIMIT
		return LIMIT + mod if mod < 0
		return mod

	DIRSTR = (dir) -> __DIRSTR__[dir%LIMIT]

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
			@setSquareAt(x,y,e)

			e.randomizeDirection()
			if preventMatching
				while @matching(e) then e.randomizeDirection()
			else e.justInserted()

			e.bind('RotateEnd', @checkConditions)
			e.bind('InsertEnd', @checkConditions)
			e.bind('MoveEnd', @checkConditions)
			e.bind('ExplodeEnd', @removeAndReplace)

		setSquareAt: (x, y, e) -> @_grid[x][y] = e
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

		printGridState: ->
			for row in [0..(ROWS-1)]
				str = ''
				for col in [0..(COLS-1)]
					sq = @getSquareAt(col,row)
					if sq?
						if sq.hasExploded() then str += "*"
						else str += DIRSTR(sq.getDirection())
					else str += "_"
				console.log str
			console.log(' ')

		nullOut: (e) ->
			@setSquareAt(e.gridX, e.gridY, null)

		detonate: (e) ->
			e.explode()
			@nullOut(e)

		checkConditions: (e) =>
			@printGridState()
			return if e.hasExploded()
			toCheck = @matching(e)
			if toCheck?
				@detonate(e)
				@detonate(toCheck)

		removeAndReplace: (e) =>
			{gridX, gridY} = e
			e.destroy()
			switch e.getDirection()
				when UP then @shiftStartingAt(gridX, gridY, 0, -1)
				when DOWN then @shiftStartingAt(gridX, gridY, 0, 1)
				when LEFT then @shiftStartingAt(gridX, gridY, -1, 0)
				when RIGHT then @shiftStartingAt(gridX, gridY, 1, 0)

			return

		shiftStartingAt: (x, y, dx, dy) ->
			for col in [(x-dx)..END(-dx, x, -1, COLS)]
				for row in [(y-dy)..END(-dy, y, -1, ROWS)]
					sq = @getSquareAt(col, row)
					if sq? then @moveWithinGrid(sq, dx, dy)
					else @newSquareAt(col+dx, row+dy)
			return

		moveWithinGrid: (e, dx, dy) ->
			return unless e? and not e.hasExploded()
			@setSquareAt(e.gridX,e.gridY,null)
			e.gridX += dx
			e.gridY += dy
			@setSquareAt(e.gridX,e.gridY,e)
			e.moveTo(GRIDLOC(e.gridX), GRIDLOC(e.gridY))

	return Grid