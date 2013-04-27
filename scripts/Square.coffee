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
			@bind('MouseDown', @MouseDown)
			@bind('MouseUp', @MouseUp)

		Click: (e) ->
			if @ignoreClick
				@ignoreClick = no
				return

			next = NEXT(@attr('sqdir'))
			@attr('sqdir', next)
			@tween({
				rotation: if next is 0 then DEG(LIMIT) else DEG(next)
			}, 15)
			@unbind('TweenEnd', @TweenEnd)
			@bind('TweenEnd', @TweenEnd)

		TweenEnd: (e) ->
			if @rotation is 360 then @rotation = 0
			@unbind('TweenEnd', @TweenEnd)

		MouseOver: (e) ->
			console.log 'over', e
			@highlight(15)
			@arrow.highlight(15)

		MouseOut: (e) ->
			@unhighlight(15)
			@arrow.unhighlight(15)
			@endDragging()

		MouseDown: (e) ->
			@dragging = yes
			@dragStartX = e.realX
			@dragStartY = e.realY
			@bind('MouseMove', @MouseMove)

		endDragging: ->
			return unless @dragging
			@dragging = no
			@tween({x: @anchorX, y: @anchorY}, 15)
			@unbind('MouseMove', @MouseMove)

		MouseUp: (e) ->
			@endDragging()

		MouseMove: (e) ->
			@ignoreClick = yes
			switch @attr('sqdir')
				when UP then @adjustUp(e)
				when RIGHT then @adjustRight(e)
				when DOWN then @adjustDown(e)
				when LEFT then @adjustLeft(e)

		adjustUp: (e) ->
			return unless e.webkitMovementY
			ydiff = e.realY - @lastY
			totalYDiff = e.realY - @dragStartY
			if totalYDiff < -@h or totalYDiff > 0 then return
			if @y + ydiff > @anchorY then return
			@lastY = e.realY
			@shift(0, ydiff)

		adjustDown: (e) ->
			return unless e.webkitMovementY
			ydiff = e.realY - @lastY
			totalYDiff = e.realY - @dragStartY
			if totalYDiff > @h or totalYDiff < 0 then return
			if @y + ydiff < @anchorY then return
			@lastY = e.realY
			@shift(0, ydiff)

		adjustRight: (e) ->
			return unless e.webkitMovementX

		adjustLeft: (e) ->
			return unless e.webkitMovementX

		randomizeDirection: ->
			dir = ~~(Math.random() * (LIMIT));
			@attr('sqdir', dir)
			@rotation = dir*90;

		anchorAt: (x,y) ->
			@anchorX = x
			@anchorY = y
			@attr({x:x, y:y})

	return key