define ['Crafty', 'components/TweenColor'], (Crafty, TweenColor) ->
	key = 'Highlighter'
	Crafty.c key,
		init: ->
			@requires(TweenColor)

		baseColor: (r,g,b) ->
			@_h_base = if arguments.length is 1 then r else {r:r, g:g, b:b}
			@rgb(@_h_base)

		highColor: (r,g,b) ->
			@_h_high = if arguments.length is 1 then r else {r:r, g:g, b:b}

		highlight: (frames = 0) ->
			@tweenColor(@_h_high, frames)

		unhighlight: (frames = 0) ->
			@tweenColor(@_h_base, frames)

	return key