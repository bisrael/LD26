define ['Crafty', 'Grid'], (Crafty, Grid) ->
	Game =
		start: ->
			Crafty.init(480, 640)
			Crafty.background('white')
			new Grid()

	return Game