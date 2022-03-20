

import 'package:injector/injector.dart';
import 'package:serializable_data/serializable_data.dart';
import 'package:test/test.dart';
import '../beta/mock_firebase_service.dart';

void main() {

  var mock = MockFirebaseService();
  var reader = DatabaseReader(mock);
  late TestObject firm;

  group('Test DatabaseReader', () {

    setUp( ()  async {
      mock = MockFirebaseService();
      reader = DatabaseReader(mock);

      var club1 = TestObject();
      club1.set('name', 'L&G Mortgage Club');
      club1.set('type', 'club');

      await mock.set(club1.dbReference, club1.data);

      var club2 = TestObject();
      club2.set('type', 'club');
      club2.set('name', 'Pink Mortgage Club');

      await mock.set(club2.dbReference, club2.data);

      firm = TestObject();
      firm.set('type', 'firm');
      firm.set('name', 'Greens');

      await mock.set(firm.dbReference, firm.data);

      Injector.appInstance.registerDependency<TestObject>(() => TestObject(), override: true);
      Injector.appInstance.registerDependency<PersistableDataObject>(() => TestObject(), override: true, dependencyName: 'Test');
    });

    group('Test query', () {
      test('When I run a query that returns more than one entry I expect them all to be returned', () async {

        var response = await reader.query<TestObject>( field: 'type', value: 'club');
        expect (response.length, 2);
        expect (response.first is TestObject, true);

        response = await reader.query(ref: 'Test', field: 'type', value: 'club');
        expect (response.length, 2);
        expect (response.first is TestObject, true);
      });

      test('When I run a query that returns one entry I expect them all to be returned', () async {

        var response = await reader.query<TestObject>( field: 'type', value: 'firm');
        expect (response.length, 1);
        expect (response.first is TestObject, true);

        response = await reader.query(ref: 'Test', field: 'type', value: 'firm');
        expect (response.length, 1);
        expect (response.first is TestObject, true);

        expect(response.first.isOnDatabase, true);
        expect(response.first.isUpdated, false);
      });

      test('When I run a query that returns no entries I expect an empty response', () async {

        var response = await reader.query<TestObject>( field: 'type', value: 'duck');
        expect (response.isEmpty, true);

        response = await reader.query(ref: 'Test', field: 'type', value: 'duck');
        expect (response.isEmpty, true);

      });
    });

    group('Test get', ()
    {
      test('When I run get a record that exists I expect it to be returned', () async {
        var response = await reader.get<TestObject>(firm.id);
        expect(response is TestObject, true);

        expect(response.isOnDatabase, true);
        expect(response.isUpdated, false);

      });

      test('When I run get a record that does not exist I expect an exception.', () async {

        try {
          await reader.get<TestObject>('12345');
          expect(true, false);
        } catch (ex) {
          expect(ex is DataObjectException,  true);
        }
      });
    });
  });
}

class TestObject extends PersistableDataObject {
  TestObject({Map<String, dynamic>? data}) : super('Test',  data: data);
}