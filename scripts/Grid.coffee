define ['Globals', 'Crafty', 'Square'], (g, Crafty, Square) ->

	class Grid
		constructor: (levelData) ->
			@_e = Crafty.e('2D, Canvas')

			@setLevelData(levelData)
			@establishGrid()
			@center()

		destroy: ->
			@_grid = null
			@_e.destroy()

		setLevelData: (data) ->
			@_levelData = data
			@_cols = data.length
			@_colMax = @_cols - 1
			@_rows = 1
			@_rowMax = 0
			@offsetX = 0
			@offsetY = 0

		isEstablished: -> !!@_grid

		newLevel: (data) ->
			@clearGrid()
			@setLevelData(data)
			@establishGrid()
			@center()

		establishGrid: ->
			@_grid = []
			for col in [0..@_colMax]
				@_grid[col] = []
				rowlen = @_levelData[col].length
				@_rowMax = (@_rows = Math.max(rowlen, @_rows)) - 1
				for row in [0..rowlen-1]
					@newSquareAt(col, row, @_levelData[col][row])

		newSquareAt: (x, y, dir) ->
			return unless ~dir
			e = Crafty.e(Square)
			e.setDirection(dir)
			e.justInserted()

			@setSquareAt(x, y, e, no)
			@bindEvents(e, 'bind')

		bindEvents: (e, method) ->
			return unless e?
			e[method]('RotateEnd', @checkConditions)
			e[method]('InsertEnd', @checkConditions)
			e[method]('MoveEnd', @checkConditions)
			e[method]('ExplodeEnd', @removeAndReplace)

		setSquareAt: (x, y, e, animate) ->
			@_grid[x][y] = e
			return unless e
			@nullOut(e) if e.gridX? and e.gridY?
			e.setGridLocation(x, y, animate)
			@_e.attach(e)

		nullOut: (e) ->
			return unless e
			@setSquareAt(e.gridX, e.gridY, null)

		getSquareAt: (x, y) -> @_grid[x]?[y]

		getWidth: -> g.gridloc(@_cols)

		getHeight: -> g.gridloc(@_rows)

		getEntity: -> @_e

		center: (animate) ->
			{viewport} = Crafty
			size = Math.min(viewport.width, viewport.height)
			@offsetX = (size - @getWidth()) / 2
			@offsetY = (size - @getHeight()) / 2
			if animate then @_e.tween({x: @offsetX, y: @offsetY})
			else @_e.shift(@offsetX - @_e.x, @offsetY - @_e.y)

		recenter: -> @center(yes)

		matching: (e) ->
			{gridX, gridY} = e
			dir = e.getDirection()

			switch dir
				when g.up then gridY -= 1
				when g.down then gridY += 1
				when g.left then gridX -= 1
				when g.right then gridX += 1

			toCheck = @getSquareAt(gridX, gridY)
			return unless toCheck and not toCheck.hasExploded()

			checkDir = toCheck.getDirection()

			matching = switch dir
				when g.up then checkDir is g.down
				when g.down then checkDir is g.up
				when g.left then checkDir is g.right
				when g.right then checkDir is g.left

			if matching then return toCheck

		isRowBlank: (row) ->
			for col in [0..@_colMax]
				return no if @getSquareAt(col, row)
			return yes

		isColBlank: (col) ->
			for row in [0..@_rowMax]
				return no if @getSquareAt(col, row)
			return yes

		removeBlankRow: (row) ->

		removeBlankCol: (col) ->

		printGridState: ->
			for row in [0..@_rowMax]
				str = ''
				for col in [0..@_colMax]
					sq = @getSquareAt(col,row)
					if sq?
						if sq.hasExploded() then str += "*"
						else str += g.dirstr(sq.getDirection())
					else str += "_"
				console.log str
			console.log(' ')

		detonate: (e) ->
			e.explode()

		checkConditions: (e) =>
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
				when g.up then @shiftStartingAt(gridX, gridY, 0, -1)
				when g.down then @shiftStartingAt(gridX, gridY, 0, 1)
				when g.left then @shiftStartingAt(gridX, gridY, -1, 0)
				when g.right then @shiftStartingAt(gridX, gridY, 1, 0)

			return

		runForGrid: (cellCallback, colCallback) ->
			return unless @isEstablished()
			for col in [0..@_colMax]
				colCallback(col, @_grid[col]) if colCallback
				for row in [0..@_rowMax]
					cellCallback(col, row, @getSquareAt(col, row)) if cellCallback
			return

		clearGrid: -> @runForGrid (col, row, e) =>
			@nullOut(e)
			e.destroy()

		auditGrid: -> @runForGrid (col, row, e) =>
			return unless e
			if g.gridloc(e.gridX) isnt e.x or g.gridloc(e.gridY) isnt e.y
				e.color('pink')

		ensureGrid: -> @runForGrid (col, row, square) =>
			@newSquareAt(col, row, no) unless square

		shiftStartingAt: (x, y, dx, dy) ->
			startX = x - dx
			endX = g.end(-dx, startX, 0, @_colMax)
			startY = y - dy
			endY = g.end(-dy, startY, 0, @_rowMax)
			for col in [startX..endX]
				for row in [startY..endY]
					sq = @getSquareAt(col, row)
					if sq? then @moveWithinGrid(sq, dx, dy)
			return

		moveWithinGrid: (e, dx, dy) ->
			return unless e? and not e.hasExploded()
			newX = e.gridX + dx
			newY = e.gridY + dy
			@setSquareAt(newX, newY, e, yes) unless @getSquareAt(newX, newY)

	return Grid