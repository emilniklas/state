part of state;

abstract class CreateEvent {

  final String key;

  final dynamic value;
}

class _CreateEvent implements CreateEvent {

  final dynamic key;

  final dynamic value;

  _CreateEvent(this.key, this.value);

  toString() {
    return 'CreateEvent([$key] was created with [$value])';
  }
}