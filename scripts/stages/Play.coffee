define ['Globals',
				'Crafty',
				'Grid',
				'ColorScheme',
				'components/Highlighter']
, (g, Crafty, Grid, Scheme, Highlighter) ->

	class Play
		constructor: ->
			@_level = 0
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


			@_hud.shift(0, @_boardSize)

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

		hideLevelNum: =>
			e = @_eLevel
			e.tween({alpha: 0}, 60)
			e.unbind('TweenEnd', @hideLevelNum)
			e.bind('TweenEnd', @loadLevel)

		loadLevel: =>
			@_eLevel.text(@_level)
			@level = g.levelData[@_level]
			@ensureGrid(@level.data)

		ensureGrid: (data) ->
			@grid = new Grid(data)
			@grid.bind('Victory', @Victory)

		Victory: (grid) =>
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