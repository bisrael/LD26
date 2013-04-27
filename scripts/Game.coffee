require ['Crafty', 'Square'], (Crafty, Square) ->
	Game =
		start: ->
			Crafty.init(480, 640)
			Crafty.background('green')

	return Game