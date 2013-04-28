define [
	'Crafty'
	'stages/Editor'
	'stages/Play'
], (Crafty, Editor, Play) ->

	class Game
		constructor: ->
			Crafty.init(480, 640)
			Crafty.background('white')

		startPlay: ->	Crafty.scene(Play)

		startEditor: -> Crafty.scene(Editor)

	return Game