import 'package:state/state.dart';
import 'package:guinness/guinness.dart';
import 'package:matcher/matcher.dart' as to;

main() {

  describe('State', () {

    State state;

    it('wraps a map', () {

      state = new State.fromMap({
        'keyOne': 'valueOne',
        'map': {
          'keyTwo': 'valueTwo',
          'keyThree': 'valueThree',
        },
      });

      expect(state['keyOne'], to.equals('valueOne'));
      expect(state['map']['keyTwo'], to.equals('valueTwo'));
      expect(state['map']['keyThree'], to.equals('valueThree'));
    });

    it('wraps a list', () {

      state = new State.fromMap([
        'itemOne',
        'itemTwo',
        [
          'itemThree',
          'itemFour',
        ],
      ]);

      state.apply([
        'hej'
      ]);

      expect(state[0], to.equals('hej'));
      expect(state[1], to.equals('itemTwo'));
      expect(state[2][0], to.equals('itemThree'));
      expect(state[2][1], to.equals('itemFour'));
    });

    it('wraps a combinated map/list object', () {

      state = new State.fromMap({
        'list': [
          'item'
        ],
      });

      expect(state['list'][0], to.equals('item'));
    });

    describe('when it is populated', () {

      beforeEach(() {

        state = new State.fromMap({
          'key': 'value',
          'list': [
            'item',
            'item',
          ],
          'map': {
            'sub-key': 'sub-value'
          },
          'list-of-map': [
            {'map-key': 'map-value'},
            {'map-key': 'map-value'},
          ],
        });
      });

      it('can be watched for changes', () async {

        state['map']['sub-key'] = 'changed';

        var called = false;

        state.change.listen((ChangeEvent event) {

          called = true;

          expect(event.key, to.equals('map.sub-key'));
          expect(event.oldValue, to.equals('sub-value'));
          expect(event.newValue, to.equals('changed'));
        });

        await null;

        expect(called, to.equals(true));
      });

      it('can be watched for created nodes', () async {

        state['map']['new-key'] = 'created';

        var called = false;

        state.create.listen((CreateEvent event) {

          called = true;

          expect(event.key, to.equals('map.new-key'));
          expect(event.value, to.equals('created'));
        });

        await null;

        expect(called, to.equals(true));
      });

      it('can be watched for deleted nodes', () async {

        state['map'].remove('sub-key');

        var called = false;

        state.delete.listen((DeleteEvent event) {

          called = true;

          expect(event.key, to.equals('map.sub-key'));
          expect(event.value, to.equals('sub-value'));
        });

        await null;

        expect(called, to.equals(true));
      });
    });
  });
}
