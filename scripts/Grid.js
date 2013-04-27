// Generated by CoffeeScript 1.6.2
define(['Crafty', 'Square'], function(Crafty, Square) {
  var COLS, GRIDLOC, GUTTER, Grid, OFFSET, ROWS, SQSIZE;

  OFFSET = 100;
  GUTTER = 10;
  SQSIZE = 50;
  COLS = 5;
  ROWS = 5;
  GRIDLOC = function(n) {
    return n * (SQSIZE + GUTTER) + OFFSET;
  };
  Grid = (function() {
    function Grid() {
      var col, row, _i, _j, _ref, _ref1;

      this._grid = [];
      for (col = _i = 0, _ref = COLS - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; col = 0 <= _ref ? ++_i : --_i) {
        this._grid[col] = [];
        for (row = _j = 0, _ref1 = ROWS - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; row = 0 <= _ref1 ? ++_j : --_j) {
          this.newSquareAt(col, row);
        }
      }
    }

    Grid.prototype.newSquareAt = function(x, y) {
      var e;

      e = Crafty.e(Square).anchorAt(GRIDLOC(x), GRIDLOC(y));
      e.randomizeDirection();
      return this._grid[x][y] = e;
    };

    return Grid;

  })();
  return Grid;
});