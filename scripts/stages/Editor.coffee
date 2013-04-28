define ['Globals', 'Crafty', 'Grid'], (g, Crafty, Grid) ->

	blankGrid = (w,h) ->
		ret = []
		for x in [0..w-1]
			ret[x] = []
			for y in [0..h-1]
				ret[x][y] = g.up

	class EditorGrid extends Grid
		constructor: ->
			super(blankGrid(4,4))
			@showEditorControls()

		showEditorControls: ->


	editor = null

	stageInit = ->
		console.log 'loading editor stage'
		editor = new EditorGrid()

	stageUninit = ->
		console.log 'unloading editor stage'
		editor.destroy()

	key = 'Editor'
	Crafty.scene(key, stageInit, stageUninit)
	return key