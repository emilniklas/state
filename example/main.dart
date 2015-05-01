import 'package:state/state.dart';

main() {

  var state = new State.fromMap({
    'key': 'initial value'
  });

  state.listen((String key, newValue, oldValue) {

    print('$key was changed from $oldValue to $newValue');
  });

  state['key'] = 'new value';
}