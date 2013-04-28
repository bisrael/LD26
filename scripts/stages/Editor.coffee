define ['Globals',
				'Crafty',
				'Grid',
				'ColorScheme',
				'components/Highlighter']
, (g, Crafty, Grid, Scheme, Highlighter) ->
	blankGrid = (w,h) ->
		ret = []
		for x in [0..w-1]
			ret[x] = []
			for y in [0..h-1]
				ret[x][y] = g.up

	class EditorGrid extends Grid
		constructor: ->
			super(blankGrid(3,3))

			@showEditorControls()
			@saveState()
			@printState()

		_stateCol: (col) =>
			@_state[col] = []

		_stateCell: (col, row, e) =>
			dir = if e then e.getDirection() else g.blank
			@_state[col][row] = dir

		saveState: =>
			@_state = []
			@runForGrid(@_stateCell, @_stateCol)
			@printState()

		getState: -> JSON.stringify(@_state)

		printState: => console.log(@getState())

		resetState: => @newLevel(@_state, no)

		bindEvents: (e, method) ->
			super
			return unless e
			opp = if method is 'bind' then 'unbind' else 'bind'
			e[opp]('MiddleClick', @editorRemove)

		editorRemove: (e) =>
			@removeSquare(e)
			colRemoved = @checkAndRemoveColIfBlank(e.gridX, yes)
			rowRemoved = @checkAndRemoveRowIfBlank(e.gridY, yes)
			if colRemoved or rowRemoved
				@repositionAll(yes)
				@recenter()

		pauseEvents: ->	@runForGrid((col,row,e) => @bindEvents(e, 'unbind'))
		unpauseEvents: ->	@runForGrid((col,row,e) => @bindEvents(e, 'bind'))

		createText: (o) ->
			e = Crafty.e("2D, Canvas, Text")
			e.textFont(o.textFont) if o.textFont
			e.textColor(o.textColor) if o.textColor
			e.text(o.text) if o.text
			return e

		createButton: (o = {}, onClick) ->
			e = Crafty.e("2D, Mouse, Canvas, Color, #{Highlighter}")
			e.w = o.w if o.w?
			e.h = o.h if o.h?

			x = ((o.x or 0) + @offsetX)
			y = ((o.y or 0) + @offsetY)
			e.shift(x, y)

			e.baseColor(o.baseColor) if o.baseColor
			e.highColor(o.highColor) if o.highColor
			e.bindHighlightMouseEvents() if o.baseColor or o.highColor
			e.bind('Click', onClick) if onClick

		showEditorControls: ->
			w = 100
			o =
				x: (@getWidth() - (4*(w+g.gutter))) / 2
				y: @getHeight() + 10*g.gutter
				w: w
				h: 20
				baseColor: Scheme.tertiary[0]
				highColor: Scheme.tertiary[4]
			incx = -> o.x += o.w + g.gutter

			@_eSave = @createButton(o, @saveState)

			incx()
			o.baseColor = Scheme.primary[0]
			o.highColor = Scheme.primary[4]
			@_ePrint = @createButton(o, @printState)

			incx()
			o.baseColor = Scheme.secondary[0]
			o.highColor = Scheme.secondary[4]
			@_eReset = @createButton(o, @resetState)

			incx()
			black = {r: 0, g: 0, b: 0}
			grey = {r: 200, g: 200, b: 200}
			darkred = {r: 102, g: 0, b: 0}
			red = {r: 230, g: 128, b: 128}
			o.baseColor = black
			o.highColor = grey
			paused = no
			@_ePause = @createButton(o, =>
				e = @_ePause
				if paused
					@unpauseEvents()
					e.rgb(grey)
					e.highColor(grey)
					e.baseColor(black)
				else
					@pauseEvents()
					e.rgb(red)
					e.highColor(red)
					e.baseColor(darkred)
				paused = !paused
			)

	window.editor = null

	stageInit = ->
		console.log 'loading editor stage'
		window.editor = new EditorGrid()

	stageUninit = ->
		console.log 'unloading editor stage'
		window.editor.destroy()
		window.editor = null

	key = 'Editor'
	Crafty.scene(key, stageInit, stageUninit)
	return key