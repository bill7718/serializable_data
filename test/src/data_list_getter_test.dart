

import 'package:injector/injector.dart';
import 'package:serializable_data/serializable_data.dart';
import 'package:test/test.dart';
import '../beta/mock_firebase_service.dart';

void main() {

  var mock = MockFirebaseService();
  var reader = DatabaseReader(mock);
  late TestObject firm;
  late TestObject club1;
  late TestObject club2;

  group('Test DataListGetter', () {

    setUp( ()  async {
      mock = MockFirebaseService();
      reader = DatabaseReader(mock);

      club1 = TestObject();
      club1.set('name', 'L&G Mortgage Club');
      club1.set('type', 'club');

      await mock.set(club1.dbReference, club1.data);

      club2 = TestObject();
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

    group('Test getList', () {
      test('Get a list with more than one item and check the results', () async {

        var getter = DataListGetter<TestObject>(filterLabel: 'type', filterValue: 'club',
            descriptionLabel: 'name', idLabel: PersistableDataObject.idLabel, reader: reader);

        var list = await getter.getList();

        expect(list.length, 2);
        expect(list.first.id, club1.id);
        expect(list.first.description, club1.get('name'));

        expect(list.last.id, club2.id);
        expect(list.last.description, club2.get('name'));
      });

      test('Get a list with one item and check the results', () async {

        var getter = DataListGetter<TestObject>(filterLabel: 'type', filterValue: 'firm',
            descriptionLabel: 'name', idLabel: PersistableDataObject.idLabel, reader: reader);

        var list = await getter.getList();

        expect(list.length, 1);
        expect(list.first.id, firm.id);
        expect(list.first.description, firm.get('name'));

      });

      test('Get a list with zero items and check the results', () async {

        var getter = DataListGetter<TestObject>(filterLabel: 'type', filterValue: 'zzzz',
            descriptionLabel: 'name', idLabel: PersistableDataObject.idLabel, reader: reader);

        var list = await getter.getList();

        expect(list.isEmpty, true);

      });

    });


  });
}

class TestObject extends PersistableDataObject {
  TestObject({Map<String, dynamic>? data}) : super('Test',  data: data);
}