// Generated by CoffeeScript 1.6.2
define(['Crafty', 'Square'], function(Crafty, Square) {
  var Game;

  Game = {
    start: function() {
      Crafty.init(480, 640);
      Crafty.background('white');
      return Crafty.e(Square);
    }
  };
  return Game;
});
