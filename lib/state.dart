import 'dart:async';

/// The `State` class is essentially a wrapper around a `Map<String, dynamic>`
/// that reports to a `Stream` whenever a key or sub-key has it's value changed.
///
/// Listen for changes with the `listen` method.
class State {

  /// The change event propagates down the tree, to the first `State` object, so
  /// we contain the parent node inside the `_parent` property.
  State _parent;

  /// `_state` is the actual map that contains the values.
  Map<String, dynamic> _state = {};

  /// `_controller` is the `StreamController` that manages the change event.
  StreamController _controller = new StreamController();

  /// A new instance of `State` can optionally be created with a parent `State`.
  State([this._parent]);

  /// The class can be instantiated with an initial state. All sub-maps will be
  /// recursively converted to sub-states.
  factory State.fromMap(Map map) => new State._fromMap(map);

  State._fromMap(Map map, [this._parent]) {

    for (var key in map.keys) {

      if (map[key] is Map) {

        _state[key] = new State._fromMap(map[key], this);

        continue;
      }

      _state[key] = map[key];
    }
  }

  /// Subscribe to the stream of changes.
  listen(onChange(String key, dynamic newValue, dynamic oldValue)) {

    _controller.stream.listen((List args) {

      Function.apply(onChange, args);
    });
  }

  /// If the value is not the same as before, set the new value to the state,
  /// and report the change.
  operator []=(key, value) {

    if (_state[key] == value) return;

    // Report
    _keyChanged(key, _state[key], value);

    // Set value
    if (value is Map) {

      return _state[key] = new State._fromMap(value, this);
    }
    _state[key] = value;
  }

  /// Read a value from the state
  operator [](key) {

    return _state[key];
  }

  /// Convert the state to a `Map<String, dynamic>`
  Map<String, dynamic> toMap() {

    Map<String, dynamic> map = {};

    for (var key in _state.keys) {

      if (_state[key] is State) {

        map[key] = _state[key].toMap();

        continue;
      }

      map[key] = _state[key];
    }
    return map;
  }

  /// Propagate the event to the parent state, or (if isn't a child)
  /// send a new event to the controller
  _keyChanged(String key, oldValue, newValue) {

    if (_parent != null) return _parent._stateChanged(this, key, oldValue, newValue);

    if (newValue is State) newValue = newValue.toMap();

    _controller.add([key, newValue, oldValue]);
  }

  /// Receive propagated event from a child state. Prepend the changed key
  /// with the child state's key, separated with a dot
  _stateChanged(State state, String key, oldValue, newValue) {

    var parentKey = _findKeyByValue(state);

    if (parentKey != null)
      key = parentKey + '.$key';

    _keyChanged(key, oldValue, newValue);
  }

  /// Find the child state's key in the map
  String _findKeyByValue(value) {

    for (var key in _state.keys) {

      if (_state[key] == value) return key;
    }
  }

  /// Apply a map to a child, recursively converting maps to states
  _applyMapToKey(Map map, String key) {

    if (!_state.containsKey(key) || !_state[key] is State) {

      return this[key] = new State._fromMap(map, this);
    }
    _state[key].apply(map);
  }

  /// Recursively apply changes to the state by comparing with `map`
  apply(Map map) {

    for (var key in map.keys) {

      if (map[key] is Map) {
        _applyMapToKey(map[key], key);
        continue;
      }

      if (this[key] == map[key]) continue;

      this[key] = map[key];
    }
  }
}