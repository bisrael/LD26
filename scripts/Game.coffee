define ['Crafty', 'Square'], (Crafty, Square) ->
	Game =
		start: ->
			Crafty.init(480, 640)
			Crafty.background('white')
			Crafty.e(Square)

	return Game