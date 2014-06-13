// Generated by CoffeeScript PHP 1.3.1
(function() {
  var TileManager;

  TileManager = (function() {

    function TileManager(_arg) {
      var templates, _ref, _ref1, _ref2;
      _ref = _arg != null ? _arg : {}, this.width = _ref.width, this.height = _ref.height, templates = _ref.templates;
      this.col_max = (_ref1 = this.width) != null ? _ref1 : this.width = 8;
      this.row_max = (_ref2 = this.height) != null ? _ref2 : this.height = 7;
      if (templates == null) {
        templates = this._generateTemplate();
      }
      this.tiles = [];
      this._populateTile({
        templates: templates
      });
      this._indexRangeBush();
    }

    TileManager.prototype._indexRangeBush = function() {
      var current, index, position, previous, type, _i, _ref, _results;
      _results = [];
      for (index = _i = 0, _ref = this.height * this.width; 0 <= _ref ? _i < _ref : _i > _ref; index = 0 <= _ref ? ++_i : --_i) {
        position = $Model.positionFromIndex({
          manager: this,
          index: index
        });
        current = this.tiles[position.index];
        previous = {
          row: this.tiles[position.index - 1],
          col: this.tiles[position.index - this.height]
        };
        _results.push((function() {
          var _j, _len, _ref1, _results1;
          _ref1 = ['col', 'row'];
          _results1 = [];
          for (_j = 0, _len = _ref1.length; _j < _len; _j++) {
            type = _ref1[_j];
            if (position[type] && previous[type].isPassable === current.isPassable) {
              current.range[type] = previous[type].range[type];
              previous[type].range[type].end = position[type];
            } else {
              current.range[type] = {
                start: position[type],
                end: position[type],
                bush: []
              };
            }
            if (!current.isGemable) {
              _results1.push(current.range[type].bush.push(current));
            } else {
              _results1.push(void 0);
            }
          }
          return _results1;
        })());
      }
      return _results;
    };

    TileManager.prototype._populateTile = function(_arg) {
      var index, template, templates, _i, _len, _results;
      templates = _arg.templates;
      _results = [];
      for (index = _i = 0, _len = templates.length; _i < _len; index = ++_i) {
        template = templates[index];
        _results.push(this.tiles[index] = new $Model.Tile(template));
      }
      return _results;
    };

    TileManager.prototype._generateTemplate = function() {
      var index, templates, _i, _ref;
      templates = [];
      for (index = _i = 0, _ref = this.width * this.height; 0 <= _ref ? _i < _ref : _i > _ref; index = 0 <= _ref ? ++_i : --_i) {
        templates[index] = {
          isGemable: Math.floor(Math.random() + 0.9),
          isPassable: Math.floor(Math.random() + 0.9)
        };
        templates[index].isPassable |= templates[index].isGemable;
        templates[index] = {
          isGemable: 1,
          isPassable: 1
        };
      }
      return templates;
    };

    TileManager.prototype.toString = function() {
      return "TODO : USE THIS INFORMATION TO SAVE";
    };

    return TileManager;

  })();

  $Model.TileManager = TileManager;

}).call(this);
