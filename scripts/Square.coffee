define ['Crafty', 'components/Highlighter', 'ColorScheme'], (Crafty, Highlighter, Scheme) ->
	key = 'Square'

	UP = 0
	RIGHT = 1
	DOWN = 2
	LEFT = 3
	LIMIT = 4

	TRUDIR = (dir) ->
		mod = dir%LIMIT
		return LIMIT + mod if mod < 0
		return mod

	__DIRSTR__ = ["U","R","D","L"]

	counter = 0

	DIRSTR = (dir) -> __DIRSTR__[TRUDIR(dir)]

	DEG = (dir) -> dir*90
	NEXT = (dir) -> (dir+1)%(LIMIT)
	PREV = (dir) -> if dir then dir-1 else LIMIT-1

	Crafty.c key,
		init: ->
			counter += 1
			@squareNum = counter
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

			@bind('MouseOver', @MouseOver)
			@bind('MouseOut', @MouseOut)
			@bind('MouseDown', @MouseDown)
			@bind('MouseUp', @MouseUp)

		MouseOver: -> @highlight(15)
		MouseOut: -> @unhighlight(15)

		beginClick: (button) ->
			@clickBegan = yes
			@clickButton = button

		endClick: ->
			@clickBegan = no

		MouseDown: (e) ->
			@beginClick(e.mouseButton)

		MouseUp: (e) ->
			if @clickBegan then @Click()
			@endClick()

		Click: (e) ->
			curr = @attr('sqdir')
			next = if @clickButton then curr - 1 else curr + 1
			if curr is undefined or next is undefined then debugger
			@attr('sqdir', next)

			console.log "(#{@gridX}, #{@gridY}) #{DIRSTR(curr)}(#{curr}) -> #{DIRSTR(next)}(#{next})"

			@unbind('TweenEnd', @RotateTweenEnd)
			@bind('TweenEnd', @RotateTweenEnd)
			@tween({
				rotation: DEG(next)
			}, 15)

		moveTo: (x,y) ->
			@unbind('TweenEnd', @MoveTweenEnd)
			@bind('TweenEnd', @MoveTweenEnd)
			@tween({
				x: x,
				y: y
			}, 15)

		MoveTweenEnd: (e) ->
			@unbind('TweenEnd', @MoveTweenEnd)
			@trigger('MoveEnd', @)

		RotateTweenEnd: (e) ->
			@unbind('TweenEnd', @RotateTweenEnd)
			@trigger('RotateEnd', @)

		randomizeDirection: ->
			dir = ~~(Math.random() * (LIMIT));
			@attr('sqdir', dir)
			@rotation = dir*90;

		getDirection: -> TRUDIR(@attr('sqdir'))

		justInserted: ->
			@attr('alpha', 0)
			@unbind('TweenEnd', @InsertTweenEnd)
			@bind('TweenEnd', @InsertTweenEnd)
			@tween({alpha: 1}, 15)

		InsertTweenEnd: ->
			@unbind('TweenEnd', @InsertTweenEnd)
			@trigger('InsertEnd', @)

		explode: ->
			@dead = yes
			@unbind('TweenEnd', @ExplodeTweenEnd)
			@bind('TweenEnd', @ExplodeTweenEnd)
			@tween({
				alpha: 0
			}, 15)
			@arrow.tween({alpha: 0}, 15)

		hasExploded: -> !!@dead

		ExplodeTweenEnd: ->
			@unbind('TweenEnd', @ExplodeTweenEnd)
			@trigger('ExplodeEnd', @)


	return key