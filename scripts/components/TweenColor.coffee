define ['Crafty'], (Crafty) ->
	key = 'TweenColor'
	Crafty.c(key, {
		init: ->
			@requires('Color')

		rgb: (r,g,b) ->
			if arguments.length
				if arguments.length is 1
					@attr(r)
					{r,g,b} = r
				else
					@attr({r:r, g:g, b:b})
				c = "rgb(#{~~r}, #{~~g}, #{~~b})"
				@color(c)
			else return {
				r: @attr('r')
				g: @attr('g')
				b: @attr('b')
			}
		isTweeningColor: -> @_twc_frameListener?
		stopTweeningColor: ->
			if @isTweeningColor()
				@unbind('EnterFrame', @_twc_frameListener)
				@_twc_frameListener = null

		tweenColor: (to, time) ->
			@stopTweeningColor()

			from = @rgb()

			to.r ?= from.r
			to.g ?= from.g
			to.b ?= from.b

			step =
				r: (to.r - from.r) / time
				g: (to.g - from.g) / time
				b: (to.b - from.b) / time

			elapsed = 0

			@_twc_frameListener = (e) ->
				elapsed += 1
				if elapsed >= time
					@stopTweeningColor()
					@rgb(to)
					return

#				from.r = ~~(from.r + step.r)
#				from.g = ~~(from.g + step.g)
#				from.b = ~~(from.b + step.b)
				from.r += step.r
				from.g += step.g
				from.b += step.b

				@rgb(from)

			@bind('EnterFrame', @_twc_frameListener)
			@bind('RemoveComponent', (c) -> @stopTweeningColor() if c is key)
	})
	return key