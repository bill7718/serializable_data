import 'package:serializable_data/serializable_data.dart';
import 'package:test/test.dart';

void main() {
  var count1 = 0;
  var count2 = 0;

  void listener1() {
    count1++;
  }

  void listener2() {
    count2++;
  }

  group('Test DataObject', () {
    var data = TestDataObject(<String, dynamic>{});

    setUp(() {
      data = TestDataObject(<String, dynamic>{});
    });

    test('get and set', () {
      expect(data.fields.isEmpty, true);
      expect(data.data.isEmpty, true);
      expect(data.validate(), null);

      data.set('value1', 1);
      expect(data.get('value1'), 1);
      expect(data.validate(fields: ['value1']), null);

      expect(data.get('value2'), null);

      var map = data.data;
      expect(map.length, 1);

      map['value1'] = 2;
      expect(data.get('value1'), 1);

      data.set('value1', null);
      expect(data.data.isEmpty, true);
    });

    test('listeners', () {
      data.set('value1', 1);
      expect(count1, 0);

      // listener only applies to the field it is linked to
      data.addListener('value1', listener1);
      data.set('value1', 2);

      expect(count1, 1);
      data.set('value2', 2);
      expect(count1, 1);

      // multiple listeners can be used
      data.addListener('value1', listener2);
      data.set('value1', 3);
      expect(count1, 2);
      expect(count2, 1);

      // removed listeners are not used
      data.removeListener('value1', listener2);
      data.set('value1', 4);
      expect(count1, 3);
      expect(count2, 1);

      // the same listener can apply to multiple fields
      data.addListener('value2', listener1);
      data.set('value2', 3);
      expect(count1, 4);

      // when a set method does not change a value then the listener is not called
      data.set('value2', 3);
      expect(count1, 4);

      // listeners update if a field is set to null
      data.set('value2', null);
      expect(count1, 5);
    });

    test('immutability', () {
      data.set(DataObject.immutableLabel, true);
      try {
        data.set('value1', 1);
        expect(true, false, reason: 'set method completes for an immutable object');
      } catch (ex) {
        expect(ex is DataObjectException, true);
      }
    });

    test('merge', () {
      data.set('value1', 1);
      TestDataObject data2 = TestDataObject(<String, dynamic>{});
      data2.set('value2', 2);
      data.merge(data2.data);
      expect(data.get('value2'), 2);
      data2.set('value1', 3);
      data.merge(data2.data);
      expect(data.get('value1'), 3);

    });

    test('toJson', () {
      data.set('value1', 1);
      var json = data.toJson();
      expect(json.toString(), '{"value1":1}');
      data.set('value2', 'hello');
      json = data.toJson();
      expect(json.toString(), '{"value1":1,"value2":"hello"}');

      data.set('value3', true);
      json = data.toJson();
      expect(json.toString(), '{"value1":1,"value2":"hello","value3":true}');

      json = data.toJson();

    });
  });
}

class TestDataObject extends DataObject {
  TestDataObject(Map<String, dynamic> data) : super(data);
}
