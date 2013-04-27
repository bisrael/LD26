define ['Crafty', 'components/Highlighter', 'ColorScheme'], (Crafty, Highlighter, Scheme) ->
	key = 'Square'

	UP = 0
	RIGHT = 1
	DOWN = 2
	LEFT = 3
	LIMIT = 4

	DEG = (dir) -> dir*90
	NEXT = (dir) -> (dir+1)%(LIMIT)

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
			next = NEXT(@attr('sqdir'))
			@attr('sqdir', next)
			@tween({
				rotation: if next is 0 then DEG(LIMIT) else DEG(next)
			}, 15)
#			fn = ->
#				@unbind('TweenEnd', fn)
#				if @rotation is 360 then @rotation = 0
#			@bind('TweenEnd', fn)

		MouseOver: (e) ->
			@highlight(15)
			@arrow.highlight(15)

		MouseOut: (e) ->
			@unhighlight(15)
			@arrow.unhighlight(15)

		randomizeDirection: ->
			dir = ~~(Math.random() * (LIMIT));
			@attr('sqdir', dir)
			@rotation = dir*90;

#		MouseDown: ->
#		MouseUp: ->
#		Drag: ->

	return key