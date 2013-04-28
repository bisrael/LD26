// Generated by CoffeeScript 1.6.2
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define(['Crafty', 'Square'], function(Crafty, Square) {
  var COLS, COL_END, DIRSTR, DOWN, END, GRIDLOC, GUTTER, Grid, HORIZ, LEFT, LIMIT, OFFSET, RIGHT, ROWS, ROW_END, SQSIZE, UP, __DIRSTR__;

  OFFSET = 100;
  GUTTER = 10;
  SQSIZE = 50;
  COLS = 5;
  ROWS = 5;
  UP = 0;
  RIGHT = 1;
  DOWN = 2;
  LEFT = 3;
  LIMIT = 4;
  __DIRSTR__ = ["U", "R", "D", "L"];
  HORIZ = function(dir) {
    return !!(dir % 2);
  };
  DIRSTR = function(dir) {
    return __DIRSTR__[dir % LIMIT];
  };
  END = function(dn, n, low, high) {
    if (!dn) {
      return n;
    }
    if (dn > 0) {
      return high;
    }
    return low;
  };
  COL_END = function(dx, x) {
    return END(dx, x, 0, COLS);
  };
  ROW_END = function(dy, y) {
    return END(dy, y, 0, ROWS);
  };
  GRIDLOC = function(n) {
    return n * (SQSIZE + GUTTER) + OFFSET;
  };
  Grid = (function() {
    function Grid() {
      this.removeAndReplace = __bind(this.removeAndReplace, this);
      this.checkConditions = __bind(this.checkConditions, this);
      var col, row, _i, _j, _ref, _ref1;

      this._grid = [];
      for (col = _i = 0, _ref = COLS - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; col = 0 <= _ref ? ++_i : --_i) {
        this._grid[col] = [];
        for (row = _j = 0, _ref1 = ROWS - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; row = 0 <= _ref1 ? ++_j : --_j) {
          this.newSquareAt(col, row, true);
        }
      }
    }

    Grid.prototype.newSquareAt = function(x, y, preventMatching) {
      var e;

      e = Crafty.e(Square).shift(GRIDLOC(x), GRIDLOC(y));
      e.gridX = x;
      e.gridY = y;
      this.setSquareAt(x, y, e);
      e.randomizeDirection();
      if (preventMatching) {
        while (this.matching(e)) {
          e.randomizeDirection();
        }
      } else {
        e.justInserted();
      }
      e.bind('RotateEnd', this.checkConditions);
      e.bind('InsertEnd', this.checkConditions);
      e.bind('MoveEnd', this.checkConditions);
      return e.bind('ExplodeEnd', this.removeAndReplace);
    };

    Grid.prototype.setSquareAt = function(x, y, e) {
      return this._grid[x][y] = e;
    };

    Grid.prototype.getSquareAt = function(x, y) {
      var _ref;

      return (_ref = this._grid[x]) != null ? _ref[y] : void 0;
    };

    Grid.prototype.matching = function(e) {
      var checkDir, dir, gridX, gridY, matching, toCheck;

      dir = e.getDirection();
      gridX = e.gridX, gridY = e.gridY;
      switch (dir) {
        case UP:
          gridY -= 1;
          break;
        case DOWN:
          gridY += 1;
          break;
        case LEFT:
          gridX -= 1;
          break;
        case RIGHT:
          gridX += 1;
      }
      toCheck = this.getSquareAt(gridX, gridY);
      if (toCheck == null) {
        return;
      }
      checkDir = toCheck.getDirection();
      matching = (function() {
        switch (dir) {
          case UP:
            return checkDir === DOWN;
          case DOWN:
            return checkDir === UP;
          case LEFT:
            return checkDir === RIGHT;
          case RIGHT:
            return checkDir === LEFT;
        }
      })();
      if (matching) {
        return toCheck;
      }
    };

    Grid.prototype.printGridState = function() {
      var col, row, sq, str, _i, _j, _ref, _ref1;

      console.log('~~~~~');
      for (row = _i = 0, _ref = ROWS - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; row = 0 <= _ref ? ++_i : --_i) {
        str = '';
        for (col = _j = 0, _ref1 = COLS - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; col = 0 <= _ref1 ? ++_j : --_j) {
          sq = this.getSquareAt(col, row);
          str += DIRSTR(sq != null ? sq.getDirection() : "_");
        }
        console.log(str);
      }
      return console.log('~~~~~');
    };

    Grid.prototype.checkConditions = function(e) {
      var toCheck;

      this.printGridState();
      toCheck = this.matching(e);
      if (toCheck != null) {
        e.explode();
        return toCheck.explode();
      }
    };

    Grid.prototype.removeAndReplace = function(e) {
      var gridX, gridY;

      gridX = e.gridX, gridY = e.gridY;
      e.destroy();
      switch (e.getDirection()) {
        case UP:
          this.shiftStartingAt(gridX, gridY, 0, -1);
          break;
        case DOWN:
          this.shiftStartingAt(gridX, gridY, 0, 1);
          break;
        case LEFT:
          this.shiftStartingAt(gridX, gridY, -1, 0);
          break;
        case RIGHT:
          this.shiftStartingAt(gridX, gridY, 1, 0);
      }
    };

    Grid.prototype.shiftStartingAt = function(x, y, dx, dy) {
      var col, row, sq, _i, _j, _ref, _ref1, _ref2, _ref3;

      for (col = _i = _ref = x - dx, _ref1 = END(-dx, x, -1, COLS); _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; col = _ref <= _ref1 ? ++_i : --_i) {
        for (row = _j = _ref2 = y - dy, _ref3 = END(-dy, y, -1, ROWS); _ref2 <= _ref3 ? _j <= _ref3 : _j >= _ref3; row = _ref2 <= _ref3 ? ++_j : --_j) {
          sq = this.getSquareAt(col, row);
          if (sq != null) {
            this.moveWithinGrid(sq, dx, dy);
          } else {
            this.newSquareAt(col + dx, row + dy);
          }
        }
      }
    };

    Grid.prototype.moveWithinGrid = function(e, dx, dy) {
      if (!((e != null) && !e.hasExploded())) {
        return;
      }
      this.setSquareAt(e.gridX, e.gridY, null);
      e.gridX += dx;
      e.gridY += dy;
      this.setSquareAt(e.gridX, e.gridY, e);
      return e.moveTo(GRIDLOC(e.gridX), GRIDLOC(e.gridY));
    };

    return Grid;

  })();
  return Grid;
});
