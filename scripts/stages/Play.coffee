define ['Globals',
				'Crafty',
				'Grid',
				'ColorScheme',
				'components/Highlighter']
, (g, Crafty, Grid, Scheme, Highlighter) ->

	class Play
		constructor: ->
			@_level = 0
			@advanceLevel()

		destroy: ->
			@grid.destroy()

		advanceLevel: ->
			@_level += 1
			@loadLevel()

		loadLevel: ->
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