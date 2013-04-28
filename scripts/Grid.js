// Generated by CoffeeScript 1.6.2
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define(['Globals', 'Crafty', 'Square'], function(g, Crafty, Square) {
  var Grid;

  Grid = (function() {
    function Grid(levelData) {
      this.removeAndReplace = __bind(this.removeAndReplace, this);
      this.removeSquare = __bind(this.removeSquare, this);
      this.checkConditions = __bind(this.checkConditions, this);      this.newLevel(levelData, false);
    }

    Grid.prototype.newLevel = function(data, animate) {
      this.resetEntity();
      this.clearGrid();
      this.setLevelData(data);
      this.establishGrid();
      return this.center(animate);
    };

    Grid.prototype.resetEntity = function() {
      if (!this._e) {
        this._e = Crafty.e('2D, Tween, Canvas');
      }
      return this._e.attr({
        x: 0,
        y: 0
      });
    };

    Grid.prototype.destroy = function() {
      this._grid = null;
      return this._e.destroy();
    };

    Grid.prototype.setLevelData = function(data) {
      var col, _i, _ref;

      this._levelData = data;
      this._cols = data.length;
      this._colMax = this._cols - 1;
      for (col = _i = 0, _ref = this._colMax; 0 <= _ref ? _i <= _ref : _i >= _ref; col = 0 <= _ref ? ++_i : --_i) {
        this._rows = Math.max(this._rows || 0, data[col].length);
      }
      this._rowMax = this._rows - 1;
      this.offsetX = 0;
      return this.offsetY = 0;
    };

    Grid.prototype.isEstablished = function() {
      return !!this._grid;
    };

    Grid.prototype.establishGrid = function() {
      var col, row, rowlen, _i, _ref, _results;

      this._grid = [];
      _results = [];
      for (col = _i = 0, _ref = this._colMax; 0 <= _ref ? _i <= _ref : _i >= _ref; col = 0 <= _ref ? ++_i : --_i) {
        this._grid[col] = [];
        rowlen = this._levelData[col].length;
        this._rowMax = (this._rows = Math.max(rowlen, this._rows)) - 1;
        _results.push((function() {
          var _j, _ref1, _results1;

          _results1 = [];
          for (row = _j = 0, _ref1 = rowlen - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; row = 0 <= _ref1 ? ++_j : --_j) {
            _results1.push(this.newSquareAt(col, row, this._levelData[col][row]));
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    Grid.prototype.newSquareAt = function(x, y, dir) {
      var e;

      if (!~dir) {
        return;
      }
      e = Crafty.e(Square);
      e.setDirection(dir);
      e.justInserted();
      this.setSquareAt(x, y, e, false);
      return this.bindEvents(e, 'bind');
    };

    Grid.prototype.bindEvents = function(e, method) {
      if (e == null) {
        return;
      }
      e[method]('RotateEnd', this.checkConditions);
      e[method]('InsertEnd', this.checkConditions);
      e[method]('MoveEnd', this.checkConditions);
      return e[method]('ExplodeEnd', this.removeAndReplace);
    };

    Grid.prototype._setSquareAt = function(x, y, e) {
      var _ref;

      if ((_ref = this._grid[x]) != null) {
        _ref[y] = e;
      }
      if (!e) {
        return false;
      }
      if ((e.gridX != null) && (e.gridY != null)) {
        this.nullOut(e);
      }
      return true;
    };

    Grid.prototype.setSquareAt = function(x, y, e, animate) {
      if (!this._setSquareAt(x, y, e)) {
        return;
      }
      e.setGridLocation(x, y, animate);
      return this._e.attach(e);
    };

    Grid.prototype.nullOut = function(e) {
      if (!e) {
        return;
      }
      return this.setSquareAt(e.gridX, e.gridY, null);
    };

    Grid.prototype.getSquareAt = function(x, y) {
      var _ref;

      return (_ref = this._grid[x]) != null ? _ref[y] : void 0;
    };

    Grid.prototype.getWidth = function() {
      return g.gridloc(this._cols);
    };

    Grid.prototype.getHeight = function() {
      return g.gridloc(this._rows);
    };

    Grid.prototype.getEntity = function() {
      return this._e;
    };

    Grid.prototype.center = function(animate) {
      var dx, dy, size, viewport;

      viewport = Crafty.viewport;
      size = Math.min(viewport.width, viewport.height);
      this.offsetX = (size - this.getWidth()) / 2;
      dx = this.offsetX - this._e.x;
      this.offsetY = (size - this.getHeight()) / 2;
      dy = this.offsetY - this._e.y;
      if (!(dx || dy)) {
        return;
      }
      if (animate) {
        return this._e.tween({
          x: this.offsetX,
          y: this.offsetY
        }, g.dur);
      } else {
        return this._e.shift(dx, dy);
      }
    };

    Grid.prototype.recenter = function() {
      return this.center(true);
    };

    Grid.prototype.matching = function(e) {
      var checkDir, dir, gridX, gridY, matching, toCheck;

      gridX = e.gridX, gridY = e.gridY;
      dir = e.getDirection();
      switch (dir) {
        case g.up:
          gridY -= 1;
          break;
        case g.down:
          gridY += 1;
          break;
        case g.left:
          gridX -= 1;
          break;
        case g.right:
          gridX += 1;
      }
      toCheck = this.getSquareAt(gridX, gridY);
      if (!(toCheck && !toCheck.hasExploded())) {
        return;
      }
      checkDir = toCheck.getDirection();
      matching = (function() {
        switch (dir) {
          case g.up:
            return checkDir === g.down;
          case g.down:
            return checkDir === g.up;
          case g.left:
            return checkDir === g.right;
          case g.right:
            return checkDir === g.left;
        }
      })();
      if (matching) {
        return toCheck;
      }
    };

    Grid.prototype.isRowBlank = function(row) {
      var col, _i, _ref;

      if (row > this._rowMax || row < 0) {
        return false;
      }
      for (col = _i = 0, _ref = this._colMax; 0 <= _ref ? _i <= _ref : _i >= _ref; col = 0 <= _ref ? ++_i : --_i) {
        if (this.getSquareAt(col, row)) {
          return false;
        }
      }
      return true;
    };

    Grid.prototype.isColBlank = function(col) {
      var row, _i, _ref;

      if (col > this._colMax || col < 0) {
        return false;
      }
      for (row = _i = 0, _ref = this._rowMax; 0 <= _ref ? _i <= _ref : _i >= _ref; row = 0 <= _ref ? ++_i : --_i) {
        if (this.getSquareAt(col, row)) {
          return false;
        }
      }
      return true;
    };

    Grid.prototype.removeBlankRow = function(row) {
      var col, lrow, _i, _j, _ref, _ref1;

      for (col = _i = 0, _ref = this._colMax; 0 <= _ref ? _i <= _ref : _i >= _ref; col = 0 <= _ref ? ++_i : --_i) {
        if (row !== this._rowMax) {
          for (lrow = _j = row, _ref1 = this._rowMax - 1; row <= _ref1 ? _j <= _ref1 : _j >= _ref1; lrow = row <= _ref1 ? ++_j : --_j) {
            this._setSquareAt(col, lrow, this.getSquareAt(col, lrow + 1));
          }
        }
        this._grid[col].pop();
      }
      this._rows -= 1;
      this._rowMax -= 1;
    };

    Grid.prototype.removeBlankCol = function(col) {
      var lcol, row, _i, _j, _ref, _ref1;

      if (col !== this._colMax) {
        for (lcol = _i = col, _ref = this._colMax - 1; col <= _ref ? _i <= _ref : _i >= _ref; lcol = col <= _ref ? ++_i : --_i) {
          for (row = _j = 0, _ref1 = this._rowMax; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; row = 0 <= _ref1 ? ++_j : --_j) {
            this._setSquareAt(lcol, row, this.getSquareAt(lcol + 1, row));
          }
        }
      }
      this._grid.pop();
      this._cols -= 1;
      this._colMax -= 1;
    };

    Grid.prototype.checkAndRemoveRowIfBlank = function(row) {
      if (this.isRowBlank(row)) {
        this.removeBlankRow(row);
        return true;
      }
      return false;
    };

    Grid.prototype.checkAndRemoveColIfBlank = function(col) {
      if (this.isColBlank(col)) {
        this.removeBlankCol(col);
        return true;
      }
      return false;
    };

    Grid.prototype.removeBlankRows = function() {
      var ret, row, _i, _ref;

      ret = false;
      for (row = _i = 0, _ref = this._rowMax; 0 <= _ref ? _i <= _ref : _i >= _ref; row = 0 <= _ref ? ++_i : --_i) {
        ret = this.checkAndRemoveRowIfBlank(row) || ret;
      }
      return ret;
    };

    Grid.prototype.removeBlankCols = function() {
      var col, ret, _i, _ref;

      ret = false;
      for (col = _i = 0, _ref = this._colMax; 0 <= _ref ? _i <= _ref : _i >= _ref; col = 0 <= _ref ? ++_i : --_i) {
        ret = this.checkAndRemoveColIfBlank(col) || ret;
      }
      return ret;
    };

    Grid.prototype.printGridState = function() {
      var col, row, sq, str, _i, _j, _ref, _ref1;

      for (row = _i = 0, _ref = this._rowMax; 0 <= _ref ? _i <= _ref : _i >= _ref; row = 0 <= _ref ? ++_i : --_i) {
        str = '';
        for (col = _j = 0, _ref1 = this._colMax; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; col = 0 <= _ref1 ? ++_j : --_j) {
          sq = this.getSquareAt(col, row);
          if (sq != null) {
            if (sq.hasExploded()) {
              str += "*";
            } else {
              str += g.dirstr(sq.getDirection());
            }
          } else {
            str += "_";
          }
        }
        console.log(str);
      }
      return console.log(' ');
    };

    Grid.prototype.detonate = function(e) {
      return e.explode();
    };

    Grid.prototype.checkConditions = function(e) {
      var toCheck;

      if (e.hasExploded()) {
        return;
      }
      toCheck = this.matching(e);
      if (toCheck != null) {
        this.detonate(e);
        return this.detonate(toCheck);
      }
    };

    Grid.prototype.repositionAll = function(animate) {
      var _this = this;

      return this.runForGrid(function(col, row, square) {
        return square.setGridLocation(col, row, animate);
      });
    };

    Grid.prototype.removeSquare = function(e) {
      this.nullOut(e);
      return e.destroy();
    };

    Grid.prototype.removeAndReplace = function(e) {
      var dir, gridX, gridY;

      gridX = e.gridX, gridY = e.gridY;
      dir = e.getDirection();
      this.removeSquare(e);
      switch (dir) {
        case g.up:
          this.shiftStartingAt(gridX, gridY, 0, -1);
          break;
        case g.down:
          this.shiftStartingAt(gridX, gridY, 0, 1);
          break;
        case g.left:
          this.shiftStartingAt(gridX, gridY, -1, 0);
          break;
        case g.right:
          this.shiftStartingAt(gridX, gridY, 1, 0);
      }
    };

    Grid.prototype.runForGrid = function(cellCallback, colCallback) {
      var col, row, _i, _j, _ref, _ref1;

      if (!this.isEstablished()) {
        return;
      }
      for (col = _i = 0, _ref = this._colMax; 0 <= _ref ? _i <= _ref : _i >= _ref; col = 0 <= _ref ? ++_i : --_i) {
        if (colCallback) {
          colCallback(col, this._grid[col]);
        }
        for (row = _j = 0, _ref1 = this._rowMax; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; row = 0 <= _ref1 ? ++_j : --_j) {
          if (cellCallback) {
            cellCallback(col, row, this.getSquareAt(col, row));
          }
        }
      }
    };

    Grid.prototype.clearGrid = function() {
      var _this = this;

      return this.runForGrid(function(col, row, e) {
        if (!e) {
          return;
        }
        _this.nullOut(e);
        return e.destroy();
      });
    };

    Grid.prototype.auditGrid = function() {
      var _this = this;

      return this.runForGrid(function(col, row, e) {
        if (!e) {
          return;
        }
        if (g.gridloc(e.gridX) !== e.x || g.gridloc(e.gridY) !== e.y) {
          return e.color('pink');
        }
      });
    };

    Grid.prototype.ensureGrid = function() {
      var _this = this;

      return this.runForGrid(function(col, row, square) {
        if (!square) {
          return _this.newSquareAt(col, row, false);
        }
      });
    };

    Grid.prototype.shiftStartingAt = function(x, y, dx, dy) {
      var col, endX, endY, row, sq, startX, startY, _i, _j;

      startX = x - dx;
      endX = g.end(-dx, startX, 0, this._colMax);
      startY = y - dy;
      endY = g.end(-dy, startY, 0, this._rowMax);
      for (col = _i = startX; startX <= endX ? _i <= endX : _i >= endX; col = startX <= endX ? ++_i : --_i) {
        for (row = _j = startY; startY <= endY ? _j <= endY : _j >= endY; row = startY <= endY ? ++_j : --_j) {
          sq = this.getSquareAt(col, row);
          if (sq != null) {
            this.moveWithinGrid(sq, dx, dy);
          }
        }
      }
    };

    Grid.prototype.moveWithinGrid = function(e, dx, dy) {
      var newX, newY;

      if (!((e != null) && !e.hasExploded())) {
        return;
      }
      newX = e.gridX + dx;
      newY = e.gridY + dy;
      if (!this.getSquareAt(newX, newY)) {
        return this.setSquareAt(newX, newY, e, true);
      }
    };

    return Grid;

  })();
  return Grid;
});
