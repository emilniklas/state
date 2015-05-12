part of state;

abstract class CreateEvent implements StateEvent {

  String key;

  final dynamic value;
}

class _CreateEvent implements CreateEvent {

  String key;

  final dynamic value;

  _CreateEvent(this.key, this.value);

  toString() {
    return 'CreateEvent([$key] was created with [$value])';
  }
}