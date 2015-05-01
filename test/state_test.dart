import 'package:state/state.dart';
import 'package:guinness/guinness.dart';
import 'package:matcher/matcher.dart' as to;

main() {

  describe('State', () {

    State state;

    beforeEach(() {

      state = new State();
    });

    it('saves stores keys and values', () {

      state['key'] = 'value';

      expect(state['key'], to.equals('value'));
    });

    it('can listen for changes', () {

      var firstSkipped = false;

      state.listen((String key, newValue, oldValue) {

        if (!firstSkipped) {
          expect(key, to.equals('dot'));
          expect(newValue, to.equals({'path':'initialValue'}));
          expect(oldValue, to.isNull);

          return firstSkipped = true;
        }
        expect(key, to.equals('dot.path'));
        expect(newValue, to.equals('newValue'));
        expect(oldValue, to.equals('initialValue'));
      });

      state['dot'] = {
        'path': 'initialValue'
      };

      state['dot']['path'] = 'newValue';
    });

    it('doesn\'t report reinserted identical values', () {

      state.listen((String key, newValue, oldValue) {

        expect(key, to.equals('dot'));
        expect(newValue, to.equals({'path':'initialValue'}));
        expect(oldValue, to.isNull);
      });

      state['dot'] = {
        'path': 'initialValue'
      };

      state['dot']['path'] = 'initialValue';
    });
  });
}
