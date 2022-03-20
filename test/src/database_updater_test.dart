import 'package:injector/injector.dart';
import 'package:serializable_data/serializable_data.dart';
import 'package:test/test.dart';
import '../beta/mock_firebase_service.dart';

void main() {
  var mock = MockFirebaseService();
  var updater = DatabaseUpdater(mock);
  var reader = DatabaseReader(mock);
  late TestObject firm;

  group('Test DatabaseReader', () {
    setUp(() async {
      mock = MockFirebaseService();
      updater = DatabaseUpdater(mock);
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
      firm.isOnDatabase = true;

      Injector.appInstance.registerDependency<TestObject>(() => TestObject(), override: true);
      Injector.appInstance.registerDependency<PersistableDataObject>(() => TestObject(), override: true, dependencyName: 'Test');
    });

    group('Test update', () {
      test(
          'When I run an update with a record that is changed then I expect the change to be written to the database and the update indicator to be reset',
          () async {
        var firm2 = TestObject();
        await updater.update(updates: [firm, firm2]);

        expect(firm.isUpdated, false);
        expect(firm2.isUpdated, false);
        expect(firm.isOnDatabase, true);
        expect(firm2.isOnDatabase, true);

        var d = await reader.get<TestObject>(firm.id);
        expect(d.id, firm.id);
      });

      test(
          'When I run an update with a record that is not changed then I expect the change to be written to the database and the update indicator to be reset',
          () async {
        var firm2 = TestObject();
        firm2.set('value1', 1);
        await updater.update(updates: [firm, firm2]);

        firm2.set('value1', 2);
        firm2.isUpdated = false;

        await updater.update(updates: [firm2]);

        var d = await reader.get<TestObject>(firm2.id);
        expect(d.id, firm2.id);
        expect(d.get('value1'), 1);
      });

      test('When I delete a record it is removed from the database', () async {
        await updater.update(deletes: [firm]);

        try {
          await reader.get<TestObject>(firm.id);
          expect(true, false);
        } catch (ex) {
          expect(ex is DataObjectException, true);
        }
      });

      test('When I update a record that is not valid I expect an exception', () async {
        try {
          firm.set('value3', 7);
          await updater.update(updates: [firm]);
          expect(true, false);
        } catch (ex) {
          expect(ex is DataObjectException, true);
        }
      });
    });
  });
}

class TestObject extends PersistableDataObject {
  TestObject({Map<String, dynamic>? data}) : super('Test', data: data);

  @override
  String? validate({List<String>? fields}) {
    if (get('value3') == 7) {
      return 'bad';
    }
  }
}
