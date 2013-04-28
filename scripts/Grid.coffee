define ['Crafty', 'Square'], (Crafty, Square) ->

	OFFSET = 5
	GUTTER = 10
	SQSIZE = 50
	COLS = 8
	ROWS = 10

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

	DIRSTR = (dir) -> __DIRSTR__[TRUDIR(dir)]

	BOUND = (n, min, max) -> Math.min(Math.max(n, min), max)

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
			@setSquareAt(x,y,e)

			e.randomizeDirection()
			if preventMatching
				while @matching(e) then e.randomizeDirection()
			else e.justInserted()

			e.bind('RotateEnd', @checkConditions)
			e.bind('InsertEnd', @checkConditions)
			e.bind('MoveEnd', @checkConditions)
			e.bind('ExplodeEnd', @removeAndReplace)

		setSquareAt: (x, y, e) ->
#			if e? and @_grid[x][y]?
#				console.log "(#{x},#{y}) was #{@_grid[x][y]} -> #{e}"
			@_grid[x][y] = e
			if e
				e.gridX = x
				e.gridY = y

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
			return if toCheck.hasExploded()
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
#			@nullOut(e)

		checkConditions: (e) =>
#			@printGridState()
			return if e.hasExploded()
			toCheck = @matching(e)
			if toCheck?
				@detonate(e)
				@detonate(toCheck)

		removeAndReplace: (e) =>
			{gridX, gridY} = e
			@nullOut(e)
			e.destroy()
			switch e.getDirection()
				when UP then @shiftStartingAt(gridX, gridY, 0, -1)
				when DOWN then @shiftStartingAt(gridX, gridY, 0, 1)
				when LEFT then @shiftStartingAt(gridX, gridY, -1, 0)
				when RIGHT then @shiftStartingAt(gridX, gridY, 1, 0)

			return

		runForGrid: (callback) ->
			for col in [0..(COLS-1)]
				for row in [0..(ROWS-1)]
					callback(col, row)
			return

		auditGrid: -> @runForGrid (col,row) =>
			e = @getSquareAt(col,row)
			return unless e
			if GRIDLOC(e.gridX) isnt e.x then console.log 'X Failed for'

		ensureGrid: -> @runForGrid (col, row) =>
			@newSquareAt(col, row, no) unless @getSquareAt(col, row)

		shiftStartingAt: (x, y, dx, dy) ->
			startX = x - dx
			endX = END(-dx, startX, 0, COLS-1)
			startY = y - dy
			endY = END(-dy, startY, 0, ROWS-1)
			for col in [startX..endX]
				for row in [startY..endY]
					sq = @getSquareAt(col, row)
					if sq? then @moveWithinGrid(sq, dx, dy)
#					else @newSquareAt(col+dx, row+dy)
			@ensureGrid()
			return

		moveWithinGrid: (e, dx, dy) ->
			return unless e? and not e.hasExploded()
			newX = e.gridX + dx
			newY = e.gridY + dy
			unless @getSquareAt(newX, newY)
				@nullOut(e)
				@setSquareAt(newX, newY, e)
				e.moveTo(GRIDLOC(newX), GRIDLOC(newY))

	return Grid