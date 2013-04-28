// Generated by CoffeeScript 1.6.2
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define(['Globals', 'Crafty', 'Grid', 'ColorScheme', 'components/Highlighter'], function(g, Crafty, Grid, Scheme, Highlighter) {
  var Play, initScene, key, play, uninitScene;

  Play = (function() {
    function Play() {
      this.Victory = __bind(this.Victory, this);
      this.loadLevel = __bind(this.loadLevel, this);
      this.hideLevelNum = __bind(this.hideLevelNum, this);      this._level = 0;
      this.createHud();
      this.advanceLevel();
    }

    Play.prototype.destroy = function() {
      this._hud.destroy();
      return this.grid.destroy();
    };

    Play.prototype.createHud = function() {
      this._boardSize = Math.min(Crafty.viewport.width, Crafty.viewport.height);
      this._hud = Crafty.e("2D, Canvas");
      this._hud.attr({
        w: Crafty.viewport.width,
        h: Crafty.viewport.height - this._boardSize
      });
      this.showLevelNum();
      return this._hud.shift(0, this._boardSize);
    };

    Play.prototype.advanceLevel = function() {
      this._level += 1;
      return this.loadLevel();
    };

    Play.prototype.showLevelNum = function() {
      var e, size;

      size = 50;
      e = Crafty.e('2D, Tween, Canvas, Text, Delay');
      this._hud.attach(e);
      e.attr({
        w: size,
        h: size,
        x: g.gutter,
        y: this._hud.h - 1.4 * size
      });
      e.textFont('size', "" + size + "px");
      e.textFont('weight', 400);
      e.textFont('lineHeight', "1.4");
      e.textFont('font', "'Roboto Condensed', 'RobotoCondensed'");
      e.text(this._level);
      return this._eLevel = e;
    };

    Play.prototype.hideLevelNum = function() {
      var e;

      e = this._eLevel;
      e.tween({
        alpha: 0
      }, 60);
      e.unbind('TweenEnd', this.hideLevelNum);
      return e.bind('TweenEnd', this.loadLevel);
    };

    Play.prototype.loadLevel = function() {
      this._eLevel.text(this._level);
      this.level = g.levelData[this._level];
      return this.ensureGrid(this.level.data);
    };

    Play.prototype.ensureGrid = function(data) {
      this.grid = new Grid(data);
      return this.grid.bind('Victory', this.Victory);
    };

    Play.prototype.Victory = function(grid) {
      this.grid.destroy();
      return this.advanceLevel();
    };

    return Play;

  })();
  play = null;
  initScene = function() {
    return play = new Play();
  };
  uninitScene = function() {
    play.destroy();
    return play = null;
  };
  key = "Play";
  Crafty.scene(key, initScene, uninitScene);
  return key;
});
