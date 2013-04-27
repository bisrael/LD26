require ['Crafty'], (Crafty) ->
	key = 'Square'
	Crafty.c key,
		init: ->
			@requires('2D, Canvas')

	return key