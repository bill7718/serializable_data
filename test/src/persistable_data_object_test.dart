
import 'package:injector/injector.dart';
import 'package:serializable_data/src/persistable_data_object.dart';
import 'package:test/test.dart';

void main() {
  group('PersistableDataObject', () {

    var data = TestObject();

    setUp(() {
      data = TestObject();
    });

    test('Test PersistableDataObject', () {

      expect(data.isUpdated, false);

      expect(data.type, 'Test');

      expect(data.data.length,  1);
      expect(data.validate(), null);

      data.set('value1', 1);
      expect(data.get('value1'), 1);
      expect(data.validate(fields: ['value1']), null);
      expect(data.isUpdated, true);


      expect(data.id.length, 32);
      expect(data.dbReference, 'Test/${data.id}');

      expect(data.id, data.get(PersistableDataObject.idLabel));
    });

    test('Test buildDBReference', () {
      expect(PersistableDataObject.buildDBReference('Hello', '12345'), 'Hello/12345');
    });

  });

  test('Test PersistableDataObject', () {
    var data = TestObject(data: <String, dynamic>{ 'value1': 'hello'});
    expect(data.isUpdated, false);
    expect(data.get('value1'), 'hello');
    data.set('value2', 12);
    expect(data.isUpdated, true);
  });

  test('Test clone', () {

    Injector.appInstance.registerDependency<TestObject>(() => TestObject());

    var data = TestObject(data: <String, dynamic>{ 'value1': 'hello'});
    expect(data.isUpdated, false);
    expect(data.isOnDatabase, false);
    var data2 = PersistableDataObject.clone<TestObject>(data)!;

    expect(data2.get('value1'), 'hello');
    expect(data2.isUpdated, false);
    expect(data2.isOnDatabase, false);
    expect(data.id, data2.id);

    data.isUpdated = true;
    data.isOnDatabase = true;
    var data3 = PersistableDataObject.clone<TestObject>(data)!;

    expect(data3.get('value1'), 'hello');
    expect(data3.isUpdated, true);
    expect(data3.isOnDatabase, true);
    expect(data.id, data3.id);

    var data4 = PersistableDataObject.clone<TestObject>(null);
    expect(data4, null);
  });
}


class TestObject extends PersistableDataObject {
  TestObject({Map<String, dynamic>? data}) : super('Test',  data: data);
}

