library state;

import 'dart:async';

part 'state_event.dart';
part 'change_event.dart';
part 'create_event.dart';
part 'delete_event.dart';

class State implements Map<String, dynamic>, List {

  dynamic _bucket;

  State _parent;

  var _parentKey;

  bool _initialized = false;

  StreamController<ChangeEvent> _changeController = new StreamController();

  Stream<ChangeEvent> get change => _changeController.stream;

  StreamController<CreateEvent> _createController = new StreamController();

  Stream<CreateEvent> get create => _createController.stream;

  StreamController<DeleteEvent> _deleteController = new StreamController();

  Stream<DeleteEvent> get delete => _deleteController.stream;

  State() {
    _initialized = true;
  }

  operator [](key) {

    return _bucket[key];
  }

  operator []=(key, value) {

    if (value is Map || value is List) {
      return _bucket[key] = new State._fromBucket(value, this, key);
    }

    var oldValue = _bucket[key];

    if (oldValue == value) return;

    bool create = !_hasKey(key);

    _bucket[key] = value;

    if (_initialized) {
      if (create) {
        return _onCreate(key, value);
      }
      _onChange(key, value, oldValue);
    }
  }

  _hasKey(key) {

    if (_bucket is Map)
      return _bucket.containsKey(key);

    return _bucket.length >= key + 1;
  }

  State._plain();

  factory State.fromMap(Map map) => new State._fromBucket(map);

  factory State.fromList(List list) => new State._fromBucket(list.toList());

  factory State._fromBucket(bucket, [State parent, parentKey]) {

    var state = new State._plain()
      .._parent = parent
      .._parentKey = parentKey;

    if (bucket is State) {
      if (bucket._bucket is Map)
        state._bucket = {};
      else
        state._bucket = [];
    }
    else if (bucket is Map)
      state._bucket = {};
    else
      state._bucket = [];

    state.apply((bucket is State) ? bucket.raw() : bucket);

    state._initialized = true;
    return state;
  }

  apply(bucket) {

    if (bucket.runtimeType != _bucket.runtimeType) {

      throw new Exception('Can\'t apply ${bucket.runtimeType} to ${_bucket.runtimeType}');
    }

    if (bucket is Map)
      _applyMap(bucket);
    else
      _applyList(bucket.toList());
  }

  _applyToKey(key, value) {

    if (value is Map) {

      return this[key] = new State._fromBucket(value, this, key);
    }

    if (value is List) {

      return this[key] = new State._fromBucket(value.toList(), this, key);
    }

    this[key] = value;
  }

  _applyMap(Map map) {

    map.forEach((key, value) {

      _applyToKey(key, value);
    });
  }

  _applyList(List list) {

    for (var i = 0; i < list.length; ++i) {

      if (_bucket.length == i) {

        _bucket.add(null);
      }

      _applyToKey(i, list[i]);
    }
  }

  _onChange(key, newValue, oldValue) {

    _changeController.add(new _ChangeEvent(
        key,
        newValue,
        oldValue
    ));

    if (_parent != null) {

      _parent._onChange('$_parentKey.$key', newValue, oldValue);
    }
  }

  _onCreate(key, value) {

    _createController.add(new _CreateEvent(
        key,
        value
    ));

    if (_parent != null) {

      _parent._onCreate('$_parentKey.$key', value);
    }
  }

  _onDelete(key, value) {

    _deleteController.add(new _DeleteEvent(
        key,
        value
    ));

    if (_parent != null) {

      _parent._onDelete('$_parentKey.$key', value);
    }
  }

  raw() {
    var output;
    if (_bucket is Map) {

      output = {};

      _bucket.forEach((key, value) {

        if (value is State) {

          return output[key] = value.raw();
        }
        output[key] = value;
      });
    }
    else {

      output = [];

      _bucket.forEach((value) {

        if (value is State) {

          return output.add(value.raw());
        }
        output.add(value);
      });
    }
    return output;
  }

  toString() {

    return 'State(${raw()})';
  }

  bool containsValue(Object value) => _bucket.containsValue(value);

  bool containsKey(Object key) => _bucket.containsKey(key);

  dynamic putIfAbsent(String key, dynamic ifAbsent()) => _putIfAbsent(key, ifAbsent);

  _putIfAbsent(String key, dynamic ifAbsent()) {

    return _bucket.putIfAbsent(key, ifAbsent);
  }

  void addAll(other) => _addAll(other);

  _addAll(other) {

    return _bucket.addAll(other);
  }

  dynamic remove(something) => _remove(something);

  dynamic _remove(something) {

    var key;

    if (_bucket is Map) {
      key = something;
    }
    else {
      key = indexOf(something);
    }

    var value = _bucket[key];

    _bucket.remove(something);

    _onDelete(key, value);
  }

  void clear() => _clear();

  void _clear() {
    return _bucket.clear();
  }

  void forEach(void f(String key, dynamic value)) => _bucket.forEach(f);

  Iterable<String> get keys => _bucket.keys;

  Iterable<dynamic> get values => _bucket.values;

  int get length => _bucket.length;

  bool get isEmpty => _bucket.isEmpty;

  bool get isNotEmpty => _bucket.isNotEmpty;

  void set length(int newLength) => _bucket.length(newLength);

  void add(dynamic value) => _add(value);

  void _add(dynamic value) {
    return _bucket.add(value);
  }

  Iterable<dynamic> get reversed => _bucket.reversed;

  void sort([int compare(dynamic a, dynamic b)]) => _bucket.sort(compare);

  void shuffle([Random random]) => _shuffle(random);

  void _shuffle([Random random]) {
    return _bucket.shuffle(random);
  }

  int indexOf(dynamic element, [int start = 0]) => _bucket.indexOf(element, start);

  int lastIndexOf(dynamic element, [int start]) => _bucket.lastIndexOf(element, start);

  void insert(int index, dynamic element) => _insert(index, element);

  void _insert(int index, dynamic element) {
    return _bucket.insert(index, element);
  }

  void insertAll(int index, Iterable<dynamic> iterable) => _insertAll(index, iterable);

  void _insertAll(int index, Iterable<dynamic> iterable) {
    return _bucket.insertAll(index, iterable);
  }

  void setAll(int index, Iterable<dynamic> iterable) => _setAll(index, iterable);

  void _setAll(int index, Iterable<dynamic> iterable) {
    return _bucket.setAll(index, iterable);
  }

  dynamic removeAt(int index) => _removeAt(index);

  dynamic _removeAt(int index) {
    return _bucket.removeAt(index);
  }

  dynamic removeLast() => _removeLast();

  dynamic _removeLast() {
    return _bucket.removeLast();
  }

  void removeWhere(bool test(dynamic element)) => _removeWhere(test);

  void _removeWhere(bool test(dynamic element)) {
    return _bucket.removeWhere(test);
  }

  void retainWhere(bool test(dynamic element)) => _retainWhere(test);

  void _retainWhere(bool test(dynamic element)) {
    return _bucket.retainWhere(test);
  }

  List<dynamic> sublist(int start, [int end]) => _bucket.sublist(start, end);

  Iterable<dynamic> getRange(int start, int end) => _bucket.getRange(start, end);

  void setRange(int start, int end, Iterable<dynamic> iterable, [int skipCount = 0]) => _setRange(start, end, iterable, skipCount);

  void _setRange(int start, int end, Iterable<dynamic> iterable, [int skipCount = 0]) {
    return _bucket.setRange(start, end, iterable, skipCount);
  }

  void removeRange(int start, int end) => _removeRange(start, end);

  void _removeRange(int start, int end) {
    return _bucket.removeRange(start, end);
  }

  void fillRange(int start, int end, [dynamic fillValue]) => _fillRange(start, end, fillValue);

  void _fillRange(int start, int end, [dynamic fillValue]) {
    return _bucket.fillRange(start, end, fillValue);
  }

  void replaceRange(int start, int end, Iterable<dynamic> replacement) => _replaceRange(start, end, replacement);

  void _replaceRange(int start, int end, Iterable<dynamic> replacement) {
    return _bucket.replaceRange(start, end, replacement);
  }
}