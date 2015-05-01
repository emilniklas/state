part of state;

abstract class ChangeEvent {

  final String key;

  final dynamic oldValue;

  final dynamic newValue;
}

class _ChangeEvent implements ChangeEvent {

  final dynamic key;

  final dynamic oldValue;

  final dynamic newValue;

  _ChangeEvent(this.key, this.newValue, this.oldValue);

  toString() {
    return 'ChangeEvent([$key] changed from [$oldValue] to [$newValue])';
  }
}