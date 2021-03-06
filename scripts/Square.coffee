define ['Globals', 'Crafty', 'components/Highlighter', 'ColorScheme'], (g, Crafty, Highlighter, Scheme) ->
	key = 'Square'

	Crafty.c key,
		init: ->
			@dead = no
			size = 50
			@requires("2D, Tween, Canvas, Color, Mouse, #{Highlighter}")
			@w = size
			@h = size
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

			@rebind('MouseOver')
			@rebind('MouseOut')
			@rebind('MouseDown')
			@rebind('MouseUp')

		rebind: (event, callback) ->
			@unbind(event, callback or @[event])
			@bind(event, callback or @[event])

		MouseOver: -> @highlight(15)
		MouseOut: -> @unhighlight(15)

		beginClick: (button) ->
			@clickBegan = yes

		endClick: ->
			@clickBegan = no

		MouseDown: (e) ->
			@beginClick()

		MouseUp: (e) ->
			if @clickBegan then @Click(e)
			@endClick()

		Click: (e) ->
			return if @dead
			return @trigger('MiddleClick', @) if e.mouseButton is Crafty.mouseButtons.MIDDLE # primarily an editor feature
			@trigger('UserAction')
			curr = @attr('sqdir')
			next = if e.mouseButton is Crafty.mouseButtons.RIGHT then curr - 1 else curr + 1
			@rebind('TweenEnd', @RotateTweenEnd)
			@setDirection(next, yes) # yes = animated

		setGridLocation: (x, y, animated) ->
			dx = g.gridloc(x - (@gridX or 0))
			dy = g.gridloc(y - (@gridY or 0))
			@gridX = x
			@gridY = y
			if animated then @moveTo(@x + dx, @y + dy)
			else @shift(dx, dy)

		moveTo: (x,y) ->
#			if @moving then @cancelTweens()
			@moving = yes
			@rebind('TweenEnd', @MoveTweenEnd)
			@tween({ x: x, y: y	}, g.dur)

		MoveTweenEnd: (e) ->
			@moving = no
			@unbind('TweenEnd', @MoveTweenEnd)
			@trigger('MoveEnd', @)

		RotateTweenEnd: (e) ->
			@unbind('TweenEnd', @RotateTweenEnd)
			@trigger('RotateEnd', @)

		randomizeDirection: -> @setDirection(g.randomDir())

		getDirection: -> g.truedir(@attr('sqdir'))

		setDirection: (dir, animated) ->
			@attr('sqdir', dir)
			if animated then @tween({ rotation: g.deg(dir) }, g.dur)
			else @rotation = g.deg(dir);

		justInserted: ->
			@attr('alpha', 0)
			@rebind('TweenEnd', @InsertTweenEnd)
			@tween({ alpha: 1 }, g.dur)

		InsertTweenEnd: ->
			@unbind('TweenEnd', @InsertTweenEnd)
			@trigger('InsertEnd', @)

		explode: ->
			@dead = yes
#			@cancelTweens()
#			@unbind('TweenEnd')
			@rebind('TweenEnd', @ExplodeTweenEnd)
			@tween({ alpha: 0	}, g.dur)
			@arrow.tween({ alpha: 0 }, g.dur)

		hasExploded: -> !!@dead

		ExplodeTweenEnd: ->
			@unbind('TweenEnd', @ExplodeTweenEnd)
			@trigger('ExplodeEnd', @)


	return key