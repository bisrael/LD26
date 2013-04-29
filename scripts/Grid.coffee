define ['Globals', 'Crafty', 'Square'], (g, Crafty, Square) ->

	class Grid
		constructor: (levelData) ->
			@newLevel(levelData, no)

		newLevel: (data, animate) ->
			@resetEntity()
			@clearGrid()
			@setLevelData(data)
			@establishGrid()
			@center(animate)

		resetEntity: ->
			unless @_e
				@_e = Crafty.e('2D, Tween, Canvas')
				@_e.bind('TweenEnd', @Tween)
			@_e.attr({x:0,y:0})

		bind: -> @_e.bind.apply(@_e, arguments)
		unbind: -> @_e.unbind.apply(@_e, arguments)

		destroy: ->
			@runForGrid (col,row,e) =>
				e?.destroy()
			@_e.destroy()
			@_grid = null

		setLevelData: (data) ->
			@_levelData = data
			@_cols = data.length
			@_colMax = @_cols - 1

			for col in [0..@_colMax]
				@_rows = Math.max(@_rows or 0, data[col].length)
			@_rowMax = @_rows - 1
			@offsetX = 0
			@offsetY = 0
			@alive = 0

		isEstablished: -> !!@_grid

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

			@alive += 1

			@setSquareAt(x, y, e, no)
			@bindEvents(e, 'bind')

		bindEvents: (e, method) ->
			return unless e?
			e[method]('RotateEnd', @checkConditions)
			e[method]('InsertEnd', @checkConditions)
			e[method]('MoveEnd', @checkConditions)
			e[method]('ExplodeEnd', @removeAndReplace)

		_setSquareAt: (x,y,e) ->
			@_grid[x]?[y] = e
			return no unless e
			@nullOut(e) if e.gridX? and e.gridY?
			return yes

		setSquareAt: (x, y, e, animate) ->
			return unless @_setSquareAt(x, y, e)
			e.setGridLocation(x, y, animate)
			@_e.attach(e)

		nullOut: (e) ->
			return unless e
			@setSquareAt(e.gridX, e.gridY, null)

		getSquareAt: (x, y) -> @_grid[x]?[y]

		getWidth: -> g.gridloc(@_cols)

		getHeight: -> g.gridloc(@_rows)

		getEntity: -> @_e

		Tween: =>
			@_e.trigger('Centered', @)

		center: (animate) ->
			{viewport} = Crafty

			size = Math.min(viewport.width, viewport.height)

			@offsetX = (size - @getWidth()) / 2
			dx = @offsetX - @_e.x

			@offsetY = (size - @getHeight()) / 2
			dy = @offsetY - @_e.y

			return unless dx or dy
			if animate
				@_e.tween({x: @offsetX, y: @offsetY}, g.dur)
			else
				@_e.shift(dx, dy)
				@_e.trigger('Centered', @)

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
			return no if row > @_rowMax or row < 0
			for col in [0..@_colMax]
				return no if @getSquareAt(col, row)
			return yes

		isColBlank: (col) ->
			return no if col > @_colMax or col < 0
			for row in [0..@_rowMax]
				return no if @getSquareAt(col, row)
			return yes

		removeBlankRow: (row) ->
			if @_cols
				for col in [0..@_colMax]
					unless row is @_rowMax
						for lrow in [row..@_rowMax-1]
							@_setSquareAt(col, lrow, @getSquareAt(col, lrow+1))
					@_grid[col].pop()
			@_rows -= 1
			@_rowMax -= 1
			return

		removeBlankCol: (col) ->
			unless col is @_colMax
				for lcol in [col..@_colMax-1]
					if @_rows
						for row in [0..@_rowMax]
							@_setSquareAt(lcol, row, @getSquareAt(lcol+1, row))
			@_grid.pop()
			@_cols -= 1
			@_colMax -= 1
			return

		checkAndRemoveRowIfBlank: (row) ->
			if @isRowBlank(row)
				@removeBlankRow(row)
				return yes
			return no

		checkAndRemoveColIfBlank: (col) ->
			if @isColBlank(col)
				@removeBlankCol(col)
				return yes
			return no

		removeBlankRows: () ->
			ret = no
			for row in [0..@_rowMax]
				ret = @checkAndRemoveRowIfBlank(row) or ret
			return ret

		removeBlankCols: () ->
			ret = no
			for col in [0..@_colMax]
				ret = @checkAndRemoveColIfBlank(col) or ret
			return ret

		removePrimaryBlanks: (e) ->
			if g.isHorizontal(e.getDirection())
				rowRemoved = @checkAndRemoveRowIfBlank(e.gridY)
			else
				colRemoved = @checkAndRemoveColIfBlank(e.gridX)
			return colRemoved or rowRemoved

		removeSecondaryBlanks: (e) ->
			if g.isHorizontal(e.getDirection())
				colRemoved = @checkAndRemoveColIfBlank(e.gridX)
			else
				rowRemoved = @checkAndRemoveRowIfBlank(e.gridY)
			return colRemoved or rowRemoved

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

		checkVictory: ->
			if @alive is 0 or @_grid.length is 0 or (@_cols is 0 and @_rows is 0)
				@_e.trigger('Victory', @)
				return yes
			return no

		checkConditions: (e) =>
			return if e.hasExploded()
			toCheck = @matching(e)
			if toCheck?
				@detonate(e)
				@detonate(toCheck)

		repositionAll: (animate) ->
			@runForGrid (col, row, square) =>
				return unless square
				square.setGridLocation(col, row, animate)

		removeSquare: (e) =>
			@nullOut(e)
			e.destroy()
			@alive -= 1

		removeAndReplace: (e) =>
			{gridX, gridY} = e
			dir = e.getDirection()

			@removeSquare(e)
			return if @checkVictory()

			switch dir
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
			return unless e
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