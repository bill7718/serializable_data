import 'package:serializable_data/src/helper.dart';
import 'package:serializable_data/serializable_data.dart';
import 'package:test/test.dart';

void main() {
  group('Test methods in helper', () {

    setUp(() {
      // Additional setup goes here.
    });

    test('generateId', () {
      var set = <String>{};
      var i = 0;
      while (i < 999) {
        set.add(generateId());
        i++;
      }

      expect(set.length , 999);
      for (var id in set) {
        expect(id.length, 32);
      }

      var id = generateId(length: 12);
      expect(id.length, 12);

    });

    group('Test parseSingleTextItem', () {
      test('When the value can be replaced it is replaced', ()
      {
        TestDataObject object = TestDataObject(<String, dynamic>{});
        object.set('value1', 'hello');
        expect(parseSingleTextItem('Jon says {{value1}}', object), 'Jon says hello');

      });

      test('When the value cannot be replaced it is not replaced', ()
      {
        TestDataObject object = TestDataObject(<String, dynamic>{});
        object.set('value1', 'hello');
        expect(parseSingleTextItem('Jon says {{value2}}', object), 'Jon says {{value2}}');

      });

      test('When the start index is before a value that cannot be replaced then no value is replaced', ()
      {
        TestDataObject object = TestDataObject(<String, dynamic>{});
        object.set('value1', 'hello');
        expect(parseSingleTextItem('Jon says {{value2}} and {{value1}}', object), 'Jon says {{value2}} and {{value1}}');

      });

      test('When the next value after the start index is a replaceable value then that value is replaced', ()
      {
        TestDataObject object = TestDataObject(<String, dynamic>{});
        object.set('value1', 'hello');
        expect(parseSingleTextItem('Jon says {{value2}} and {{value1}}', object, start: 19), 'Jon says {{value2}} and hello');

      });
    });

    group('Test parseText', () {
      test('When the value can be replaced it is replaced', ()
      {
        TestDataObject object = TestDataObject(<String, dynamic>{});
        object.set('value1', 'hello');
        expect(parseText('Jon says {{value1}}', object), 'Jon says hello');

      });

      test('When the value cannot be replaced it is not replaced', ()
      {
        TestDataObject object = TestDataObject(<String, dynamic>{});
        object.set('value1', 'hello');
        expect(parseText('Jon says {{value2}}', object), 'Jon says {{value2}}');

      });

      test('When the start index is before a value that cannot be replaced then all replaceable values are replaced', ()
      {
        TestDataObject object = TestDataObject(<String, dynamic>{});
        object.set('value1', 'hello');
        expect(parseText('Jon says {{value2}} and {{value1}}', object), 'Jon says {{value2}} and hello');

      });
    });


    group('Test parseText', () {
      test('When the value can be replaced it is replaced', ()
      {
        TestDataObject object = TestDataObject(<String, dynamic>{});
        TestDataObject object2 = TestDataObject(<String, dynamic>{});
        object.set('value1', 'hello');
        expect(parse('Jon says {{value1}}', [object, object2] ), 'Jon says hello');

      });

      test('When the value cannot be replaced it is not replaced and the string is not returned', ()
      {
        TestDataObject object = TestDataObject(<String, dynamic>{});
        TestDataObject object2 = TestDataObject(<String, dynamic>{});
        object.set('value1', 'hello');
        expect(parse('Jon says {{value2}}', [object, object2]), '');

      });

      test('When there are items to replace in both objects then they are both replaced', ()
      {
        TestDataObject object = TestDataObject(<String, dynamic>{});
        TestDataObject object2 = TestDataObject(<String, dynamic>{});
        object.set('value1', 'hello');
        object2.set('value2', 'hi');
        expect(parse('Jon says {{value2}} and {{value1}}', [object, object2]), 'Jon says hi and hello');

      });
    });
  });
}

class TestDataObject extends DataObject {
  TestDataObject(Map<String, dynamic> data) : super(data);


}