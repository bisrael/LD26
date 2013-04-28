define ['Crafty', 'Grid', 'stages/Editor'], (Crafty, Grid, Editor) ->
	Game =
		start: ->
			Crafty.init(480, 640)
			Crafty.background('white')
			Crafty.scene(Editor)

	return Game