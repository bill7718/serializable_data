

import 'package:serializable_data/serializable_data.dart';
import 'package:test/test.dart';

void main() {
  var test1 = TestDataObject1(<String, dynamic>{});
  var test2 = TestDataObject2(<String, dynamic>{});
  var combined = CombinedDataObject([ test1, test2  ]);
  var count1 = 0;
  var count2 = 0;

  void listener1() {
    count1++;
  }

  void listener2() {
    count2++;
  }

  group('Test CombinedDataObject', () {

    setUp( () {
      test1 = TestDataObject1(<String, dynamic>{});
      test2 = TestDataObject2(<String, dynamic>{});
      combined = CombinedDataObject([ test1, test2  ]);
    });

    test('Test constructor', () {
      expect(combined.objects.length, 2);
      expect(combined.objects.first is TestDataObject1, true);
      expect(combined.objects.last is TestDataObject2, true);
    });

    group('Test get', () {
      test('A field in the first object is returned from the first object', () {
        test1.set('value1', 21);
        expect(combined.get('value1'), 21);
      });

      test('A field in the second object is returned from the second object', () {
        test1.set('value1', 21);
        test2.set('value2', 22);
        expect(combined.get('value2'), 22);
      });

      test('A field in the both objects is returned from the first object', () {
        test1.set('value1', 21);
        test1.set('value2', 22);
        test1.set('value12', 121);
        test2.set('value12', 122);
        expect(combined.get('value12'), 121);
      });

      test('A field in neither object returns null', () {
        test1.set('value1', 21);
        test1.set('value2', 22);
        expect(combined.get('not_there'), null);
      });
    });

    group('Test set', ()
    {
      test('A field in the first object is set even if it is not in the fields list', () {
        test1.set('value1', 21);
        expect(combined.get('value1'), 21);
        combined.set('value1', 22);
        expect(combined.get('value1'), 22);
      });

      test('A field in the second object is set even if it is not in the fields list', () {
        test1.set('value1', 21);
        test1.set('value2', 22);
        expect(combined.get('value2'), 22);
        combined.set('value2', 44);
        expect(combined.get('value2'), 44);
      });

      test('A field in the first object is set if it is not there because it is in the fields list', () {
        combined.set('knownField', 22);
        expect(combined.get('knownField'), 22);
        expect(test1.get('knownField'), 22);
        expect(test2.get('knownField'), null);

      });

      test('An attempt to set an unknown field throws an Exception', () {
        try {
          combined.set('unknownField', 22);
          expect(true, false);
        } catch (ex) {
          expect(ex is DataObjectException, true);
        }

      });
    });

    test('Test data', () {
      test1.set('value1', 21);
      test2.set('value2', 22);

      var merged = combined.data;
      expect(merged['value1'] , 21);
      expect(merged['value2'] , 22);
      expect(merged.length, 2);

    });

    test('Test jsonEncoder', () {
      test1.set('value1', 21);
      test2.set('value2', 22);

      var json = combined.toJson();
      expect(json.toString(), '{"value1":21,"value2":22}');
    });

    test('Test fields', () {

      expect(combined.fields.length, 3);
      expect(combined.fields.contains('knownField'), true);
      expect(combined.fields.contains('knownField2'), true);
    });

    test('listeners', () {
      combined.set('knownField', 1);
      expect(count1, 0);

      // listener only applies to the field it is linked to
      combined.addListener('knownField', listener1);
      combined.set('knownField', 2);
      expect(count1, 1);

      combined.set('knownField2', 2);
      expect(count1, 1);

      // multiple listeners can be used
      combined.addListener('knownField', listener2);
      combined.set('knownField', 3);
      expect(count1, 2);
      expect(count2, 1);

      // removed listeners are not used
      combined.removeListener('knownField', listener2);
      combined.set('knownField', 4);
      expect(count1, 3);
      expect(count2, 1);

      // the same listener can apply to multiple fields
      combined.addListener('knownField2', listener1);
      combined.set('knownField2', 3);
      expect(count1, 4);

      // when a set method does not change a value then the listener is not called
      combined.set('knownField2', 3);
      expect(count1, 4);

      // listeners update if a field is set to null
      combined.set('knownField2', null);
      expect(count1, 5);
    });


    test('Test immutable', () {
      expect(combined.immutable, false);
      test1.set(DataObject.immutableLabel, true);
      expect(combined.immutable, false);
      test2.set(DataObject.immutableLabel, true);
      expect(combined.immutable, true);

    });

    test('Test merge', () {
      try {
        combined.merge(<String, dynamic>{});
        expect(true, false);
      } catch (ex) {
        expect (ex is DataObjectException,  true);
      }

    });

    test('Test validate', () {
      expect(combined.validate(), null);
      expect(combined.validate(fields: ['invalid1']), 'bad');
    });

  });
}


class TestDataObject1 extends DataObject {
  TestDataObject1(Map<String, dynamic> data) : super(data);

  @override
  List<String> fields = ['knownField'];

  @override
  String? validate({List<String>? fields}) {
    if ((fields ?? []).contains('invalid1')) {
      return 'bad';
    }
    return null;
  }

}

class TestDataObject2 extends DataObject {
  TestDataObject2(Map<String, dynamic> data) : super(data);

  @override
  List<String> fields = ['knownField2' , 'knownField22'];
}