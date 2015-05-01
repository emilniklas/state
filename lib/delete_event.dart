part of state;

abstract class DeleteEvent {

  final String key;

  final dynamic value;
}

class _DeleteEvent implements DeleteEvent {

  final dynamic key;

  final dynamic value;

  _DeleteEvent(this.key, this.value);

  toString() {
    return 'DeleteEvent([$key] was deleted with [$value])';
  }
}