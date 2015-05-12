part of state;

abstract class ChangeEvent implements StateEvent {

  String key;

  final dynamic oldValue;

  final dynamic newValue;
}

class _ChangeEvent implements ChangeEvent {

  String key;

  final dynamic oldValue;

  final dynamic newValue;

  _ChangeEvent(String this.key, this.newValue, this.oldValue);

  toString() {
    return 'ChangeEvent([$key] changed from [$oldValue] to [$newValue])';
  }
}