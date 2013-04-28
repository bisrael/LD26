// Generated by CoffeeScript 1.6.2
define(['Crafty', 'components/Highlighter', 'ColorScheme'], function(Crafty, Highlighter, Scheme) {
  var DEG, DOWN, LEFT, LIMIT, NEXT, PREV, RIGHT, UP, key;

  key = 'Square';
  UP = 0;
  RIGHT = 1;
  DOWN = 2;
  LEFT = 3;
  LIMIT = 4;
  DEG = function(dir) {
    return dir * 90;
  };
  NEXT = function(dir) {
    return (dir + 1) % LIMIT;
  };
  PREV = function(dir) {
    if (dir) {
      return dir - 1;
    } else {
      return LIMIT - 1;
    }
  };
  Crafty.c(key, {
    init: function() {
      var size;

      size = 50;
      this.requires("2D, Tween, Canvas, Color, Mouse, " + Highlighter);
      this.attr({
        w: size,
        h: size
      });
      this.baseColor(Scheme.primary[0]);
      this.highColor(Scheme.primary[4]);
      this.origin("center");
      this.arrow = Crafty.e("2D, Canvas, Color, Tween, " + Highlighter);
      this.arrow.attr({
        w: 10,
        h: 10
      });
      this.arrow.origin(5, 25);
      this.arrow.shift(20, 0);
      this.arrow.baseColor(Scheme.secondary[0]);
      this.arrow.highColor(Scheme.secondary[4]);
      this.attach(this.arrow);
      this.bind('MouseOver', this.MouseOver);
      this.bind('MouseOut', this.MouseOut);
      this.bind('MouseDown', this.MouseDown);
      return this.bind('MouseUp', this.MouseUp);
    },
    MouseOver: function() {
      return this.highlight(15);
    },
    MouseOut: function() {
      return this.unhighlight(15);
    },
    beginClick: function(button) {
      this.clickBegan = true;
      this.clickButton = button;
      return console.log('button', button);
    },
    endClick: function() {
      return this.clickBegan = false;
    },
    MouseDown: function(e) {
      return this.beginClick(e.mouseButton);
    },
    MouseUp: function(e) {
      if (this.clickBegan) {
        this.Click();
      }
      return this.endClick();
    },
    Click: function(e) {
      var curr, next;

      curr = this.attr('sqdir');
      next = this.clickButton ? curr - 1 : curr + 1;
      this.attr('sqdir', next);
      this.unbind('TweenEnd', this.RotateTweenEnd);
      this.bind('TweenEnd', this.RotateTweenEnd);
      return this.tween({
        rotation: DEG(next)
      }, 15);
    },
    moveTo: function(x, y) {
      this.unbind('TweenEnd', this.MoveTweenEnd);
      this.bind('TweenEnd', this.MoveTweenEnd);
      return this.tween({
        x: x,
        y: y
      }, 15);
    },
    MoveTweenEnd: function(e) {
      return console.log('Move End', e);
    },
    RotateTweenEnd: function(e) {
      this.unbind('TweenEnd', this.RotateTweenEnd);
      return this.trigger('RotateEnd', this);
    },
    randomizeDirection: function() {
      var dir;

      dir = ~~(Math.random() * LIMIT);
      this.attr('sqdir', dir);
      return this.rotation = dir * 90;
    },
    getDirection: function() {
      var dir;

      dir = this.attr('sqdir');
      if (dir < 0) {
        return LIMIT - (dir % LIMIT);
      } else {
        return dir % LIMIT;
      }
    },
    explode: function() {
      this.unbind('TweenEnd', this.ExplodeTweenEnd);
      this.bind('TweenEnd', this.ExplodeTweenEnd);
      return this.tween({
        alpha: 0
      }, 15);
    },
    ExplodeTweenEnd: function() {}
  });
  return key;
});
