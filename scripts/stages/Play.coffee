define ['Globals',
				'Crafty',
				'Grid',
				'ColorScheme',
				'components/Highlighter',
				'components/TweenColor'
], (g, Crafty, Grid, Scheme, Highlighter, TweenColor) ->

	class Play
		constructor: ->
			@_level = 0
			@_score = 0
			@createHud()
			@advanceLevel()

		destroy: ->
			@_hud.destroy()
			@grid.destroy()

		createHud: ->
			@_boardSize = Math.min(Crafty.viewport.width, Crafty.viewport.height)
			@_hud = Crafty.e("2D, Canvas")
			@_hud.attr({w: Crafty.viewport.width, h: Crafty.viewport.height - @_boardSize})

			@showLevelNum()
			@showResetButton()

			@_hud.shift(0, @_boardSize)

		reset: ->
			@_level = 0
			@_score = 0
			@advanceLevel()

		advanceLevel: ->
			@_level += 1
			@loadLevel()

		showLevelNum: ->
			size = 50
			e = Crafty.e('2D, Tween, Canvas, Text, Delay')
			@_hud.attach(e)

			e.attr({ w:size,h:size, x:g.gutter, y: @_hud.h - 1.4*size})
			e.textFont('size', "#{size}px")
			e.textFont('weight', 400)
			e.textFont('lineHeight', "1.4")
			e.textFont('font', "'Roboto Condensed', 'RobotoCondensed'") # ooooo design!
			e.text(@_level)
			@_eLevel = e

		showResetButton: ->
			e = Crafty.e("2D, Tween, Canvas, #{Highlighter}")
			@_hud.attach(e)
			s = g.sqsize
			e.attr({
				w: s
				h: s
				x: @_hud.w - g.gutter - s
				y: @_hud.h - g.gutter - s
			})
			e.baseColor(Scheme.secondary[0])
			e.highColor(Scheme.secondary[4])
			e.bindHighlightMouseEvents()
			e.bind('Click', =>
				if not @level then @reset()
				else if @grid then @grid.newLevel(@level.data)
			)

		hideLevelNum: =>
			e = @_eLevel
			e.tween({alpha: 0}, 60)
			e.unbind('TweenEnd', @hideLevelNum)
			e.bind('TweenEnd', @loadLevel)

		loadLevel: =>
			@_eLevel.text("#{@_level} : #{@_score}")
			@level = g.levelData[@_level]
			if not @level then @_eLevel.text("Final Score: #{@_score}")
			else @loadIntoGrid()

		loadIntoGrid: =>
			@ensureGrid(@level.data)

		ensureGrid: (data) ->
			@grid.destroy() if @grid
			@grid = new Grid(data)
			@grid.bind('Victory', @Victory)

		Victory: (grid) =>
			actions = @grid.actions
			if actions <= @level.gold then @_score += 3
			else if actions <= @level.silver then @_score += 2
			else @_score += 1
			@grid.destroy()
			@advanceLevel()

	play = null

	initScene = ->
		play = new Play()

	uninitScene = ->
		play.destroy()
		play = null

	key = "Play"
	Crafty.scene(key, initScene, uninitScene)
	return key