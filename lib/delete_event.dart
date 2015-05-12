part of state;

abstract class DeleteEvent implements StateEvent {

  String key;

  final dynamic value;
}

class _DeleteEvent implements DeleteEvent {

  String key;

  final dynamic value;

  _DeleteEvent(this.key, this.value);

  toString() {
    return 'DeleteEvent([$key] was deleted with [$value])';
  }
}