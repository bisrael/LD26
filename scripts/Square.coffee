define ['Crafty', 'components/Highlighter', 'ColorScheme'], (Crafty, Highlighter, Scheme) ->
	key = 'Square'
	Crafty.c key,
		init: ->
			size = 50
			@requires("2D, Tween, Canvas, Color, Mouse, #{Highlighter}")
			@attr
				w: size
				h: size
			@baseColor(Scheme.primary[0])
			@highColor(Scheme.primary[4])

			@origin("center")

			@arrow = Crafty.e("2D, Canvas, Color, Tween, #{Highlighter}")
			@arrow.attr(w: 10, h: 10)
			@arrow.origin(5, 25)
			@arrow.shift(20, 0)
			@arrow.baseColor(Scheme.secondary[0])
			@arrow.highColor(Scheme.secondary[4])

			@attach(@arrow)

			@bind('Click', @Click)

			@bind('MouseOver', @MouseOver)
			@bind('MouseOut', @MouseOut)
#			@bind('MouseDown', @MouseDown)
#			@bind('MouseUp', @MouseUp)

		Click: ->
			@tween({rotation: @attr('rotation') + 90}, 15)
			#@arrow.tween({rotation: @arrow.attr('rotation') + 90}, 15)

		MouseOver: (e) ->
			@highlight(15)
			@arrow.highlight(15)

		MouseOut: (e) ->
			@unhighlight(15)
			@arrow.unhighlight(15)

#		MouseDown: ->
#		MouseUp: ->
#		Drag: ->

	return key