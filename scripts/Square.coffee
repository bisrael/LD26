define ['Crafty', 'components/TweenColor'], (Crafty, TweenColor) ->
	key = 'Square'
	Crafty.c key,
		init: ->
			@requires("2D, Tween, #{TweenColor}, Canvas, Color, Mouse")
			@attr
				x: 10
				y: 10
				w: 50
				h: 50
			@rgb(0,0,0)

			@bind('MouseOver', @MouseOver)
			@bind('MouseOut', @MouseOut)
#			@bind('MouseDown', @MouseDown)
#			@bind('MouseUp', @MouseUp)

		MouseOver: ->
			@tweenColor({r: 255, g: 0, b: 0}, 15)

		MouseOut: ->
			@tweenColor({r: 0, g: 0, b: 0}, 15)

#		MouseDown: ->
#		MouseUp: ->
#		Drag: ->

	return key