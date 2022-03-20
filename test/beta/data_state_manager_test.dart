import 'package:injector/injector.dart';
import 'package:serializable_data/serializable_data.dart';
import 'package:test/test.dart';

import 'mock_firebase_service.dart';

void main() {
  var db = MockFirebaseService();
  var map = testRelationshipSpecification();
  var manager = DataStateManager(map, DatabaseReader(db), DatabaseUpdater(db));

  group('Test DataStateManager', () {
    setUp(() {
      Injector.appInstance.clearAll();
      db = MockFirebaseService();
      registerSerializableDataDependencies();
      registerTestDependencies();
      manager = manager = DataStateManager(map, DatabaseReader(db), DatabaseUpdater(db));
    });

    group('Test getOrCreate', () {
      test('when I call the method with no id I expect a new object to be created', () async {
        var parent = await manager.getOrCreate<Parent>();
        expect(parent is Parent, true);
        expect(manager.data.keys.contains(parent.id), false);
      });

      test('when I call the method with an id I expect to get the value that is on the database', () async {
        var p = Parent();
        p.set(Parent.value1Label, 1);
        await db.set(p.dbReference, p.data);

        var parent = await manager.getOrCreate<Parent>(id: p.id);
        expect(parent is Parent, true);
        expect(manager.data.keys.contains(parent.id), false);
        expect(p.id, parent.id);
        expect(p.get(Parent.value1Label), p.get(Parent.value1Label));
      });

      test('when I call the method with an id that is not on the database or in the state object I expect an exception', () async {
        try {
          await manager.getOrCreate<Parent>(id: '1234567');
          expect(true, false);
        } catch (ex) {
          expect(true, true);
        }
      });

      test('when I call the method with an id that is in the state object I expect it be retrieved ', () async {
        var p = await manager.getOrCreate<Parent>();
        p.set(Parent.value1Label, 1);
        await manager.setState(p);
        var parent = await manager.getOrCreate<Parent>(id: p.id);
        expect(p.id, parent.id);
      });
    });

    group('Test readRelationships', () {
      test('When I call the method with a fromId that has no relationships no items are added to the state object  ', () async {
        await manager.readRelationships('1234567');
        expect(manager.relationships.keys.isEmpty, true);
      });

      test('When I call the method with a fromId that is in the database I expect it to be added to the state object', () async {
        var rel = DataObjectRelationship.specification(map[Parent.toChild]!, '12345');
        rel.set(DataObjectRelationship.toIdLabel, '23456');
        await db.set(rel.dbReference, rel.data);

        await manager.readRelationships('12345');
        expect(manager.relationships.keys.length, 1);
      });

      test('When I call the method with a fromId more than once it does not go to the database', () async {
        var rel = DataObjectRelationship.specification(map[Parent.toChild]!, '12345');
        rel.set(DataObjectRelationship.toIdLabel, '23456');
        await db.set(rel.dbReference, rel.data);

        await manager.readRelationships('12345');
        expect(manager.relationships.keys.length, 1);

        manager.relationships.clear();

        await manager.readRelationships('12345');
        expect(manager.relationships.isEmpty, true);
      });
    });

    group('Test getOrCreateBySpecification', () {
      test('When I call getOrCreateBySpecification with a fromId that has no relationships I get back a new version of the child object  ', () async {
        var parent = await manager.getOrCreate<Parent>();
        var child = await manager.getOrCreateBySpecification<Child>(Parent.toChild, parent.id);
        expect(child is Child, true);
        expect(manager.data.isEmpty, true);
      });

      test('When I call getOrCreateBySpecification with a fromId that links to the child I expect to get the linked child ', () async {
        var parent = await manager.getOrCreate<Parent>();
        parent.set(Parent.value1Label, 1);
        await manager.setState(parent);
        var child = await manager.getOrCreateBySpecification<Child>(Parent.toChild, parent.id);
        child.set(Child.value1Label, 1);
        await manager.setState(child, spec: Parent.toChild, fromId: parent.id);
        var child2 = await manager.getOrCreateBySpecification<Child>(Parent.toChild, parent.id);
        expect(child2.id, child.id);
        expect(manager.data.length, 2);
        expect(manager.relationships.length, 1);
      });

      test('When I call getOrCreateBySpecification with values on the database but not in the state I expect the child to be returned', () async {
        var parent = await manager.getOrCreate<Parent>();
        parent.set(Parent.value1Label, 1);
        await manager.setState(parent);
        var child = await manager.getOrCreateBySpecification<Child>(Parent.toChild, parent.id);
        child.set(Child.value1Label, 1);
        await manager.setState(child, spec: Parent.toChild, fromId: parent.id);
        var child2 = await manager.getOrCreateBySpecification<Child>(Parent.toChild, parent.id);
        expect(child2.id, child.id);
        expect(manager.data.length, 2);
        expect(manager.relationships.length, 1);

        await db.set(parent.dbReference, parent.data);
        await db.set(child.dbReference, child.data);
        await db.set(manager.relationships.values.first.dbReference, manager.relationships.values.first.data);

        manager.data.clear();
        manager.relationships.clear();
        manager.fromIds.clear();
        var child3 = await manager.getOrCreateBySpecification<Child>(Parent.toChild, parent.id);
        expect(child3.id, child.id);
        expect(manager.data.length, 0);
        expect(manager.relationships.length, 1);
      });

      test('When I call getOrCreateBySpecification with values not on the database or int the state I expetc an exception', () async {
        var parent = await manager.getOrCreate<Parent>();
        parent.set(Parent.value1Label, 1);
        await manager.setState(parent);
        var child = await manager.getOrCreateBySpecification<Child>(Parent.toChild, parent.id);
        child.set(Child.value1Label, 1);
        await manager.setState(child, spec: Parent.toChild, fromId: parent.id);
        var child2 = await manager.getOrCreateBySpecification<Child>(Parent.toChild, parent.id);
        expect(child2.id, child.id);
        expect(manager.data.length, 2);
        expect(manager.relationships.length, 1);

        await db.set(manager.relationships.values.first.dbReference, manager.relationships.values.first.data);

        manager.data.clear();
        manager.relationships.clear();
        manager.fromIds.clear();

        try {
          await manager.getOrCreateBySpecification<Child>(Parent.toChild, parent.id);
          expect(true, false);
        } catch (ex) {
          expect(ex is DataStateManagerException, true, reason: ex.runtimeType.toString());
        }
      });
    });

    group('Test getOrCreateRelationshipBySpecification', () {
      test('When I call getOrCreateRelationshipBySpecification with a fromId that has a relationship to the child I get the relationship returned  ',
          () async {
        var parent = await manager.getOrCreate<Parent>();
        parent.set(Parent.value1Label, 1);
        await manager.setState(parent);
        var child = await manager.getOrCreateBySpecification<Child>(Parent.toChild, parent.id);
        child.set(Child.value1Label, 1);
        await manager.setState(child, spec: Parent.toChild, fromId: parent.id);
        var child2 = await manager.getOrCreateBySpecification<Child>(Parent.toChild, parent.id);
        expect(child2.id, child.id);
        expect(manager.data.length, 2);
        expect(manager.relationships.length, 1);
        var rel = manager.relationships.values.first;
        await db.set(parent.dbReference, parent.data);
        await db.set(child.dbReference, child.data);
        await db.set(manager.relationships.values.first.dbReference, manager.relationships.values.first.data);

        manager.data.clear();
        manager.relationships.clear();
        manager.fromIds.clear();

        var rel2 = await manager.getOrCreateRelationshipBySpecification(Parent.toChild, parent.id);
        expect(rel2.id, rel.id);
        expect(manager.data.length, 0);
        expect(manager.relationships.length, 1);
      });

      test(
          'When I call getOrCreateRelationshipBySpecification with a fromId that has does not have a relationship to the child I get a new relationship returned  ',
          () async {
        var parent = await manager.getOrCreate<Parent>();
        parent.set(Parent.value1Label, 1);
        await manager.setState(parent);
        var child = await manager.getOrCreateBySpecification<Child>(Parent.toChild, parent.id);
        child.set(Child.value1Label, 1);
        await manager.setState(child, spec: Parent.toChild, fromId: parent.id);
        var child2 = await manager.getOrCreateBySpecification<Child>(Parent.toChild, parent.id);
        expect(child2.id, child.id);
        expect(manager.data.length, 2);
        expect(manager.relationships.length, 1);
        var rel = manager.relationships.values.first;
        await db.set(parent.dbReference, parent.data);
        await db.set(child.dbReference, child.data);

        manager.data.clear();
        manager.relationships.clear();
        manager.fromIds.clear();

        var rel2 = await manager.getOrCreateRelationshipBySpecification(Parent.toChild, parent.id);
        expect(rel2.id == rel.id, false);
        expect(rel.fromId, rel2.fromId);
        expect(rel2.toId, null);
      });

      test('When I call getOrCreateRelationshipBySpecification with an invalid specification I get an exception ', () async {
        var parent = await manager.getOrCreate<Parent>();
        parent.set(Parent.value1Label, 1);
        await manager.setState(parent);
        var child = await manager.getOrCreateBySpecification<Child>(Parent.toChild, parent.id);
        child.set(Child.value1Label, 1);
        await manager.setState(child, spec: Parent.toChild, fromId: parent.id);
        var child2 = await manager.getOrCreateBySpecification<Child>(Parent.toChild, parent.id);
        expect(child2.id, child.id);
        expect(manager.data.length, 2);
        expect(manager.relationships.length, 1);
        var rel = manager.relationships.values.first;
        await db.set(parent.dbReference, parent.data);
        await db.set(child.dbReference, child.data);

        manager.data.clear();
        manager.relationships.clear();
        manager.fromIds.clear();
        try {
          await manager.getOrCreateRelationshipBySpecification('121212', parent.id);
          expect(true, false);
        } catch (ex) {
          expect(ex is DataStateManagerException, true, reason: ex.runtimeType.toString());
        }
      });
    });

    group('Test listBySpecification', () {
      test('When I call listBySpecification with a fromId that and spec that does not exist on the database', () async {
        var parent = await manager.getOrCreate<Parent>();
        parent.set(Parent.value1Label, 1);
        await manager.setState(parent);

        var list = await manager.listBySpecification<Child>(Parent.toChild, parent.id);
        expect(list.isEmpty, true);
      });

      test('When I call listBySpecification with a fromId that has one match I find one match ', () async {
        var parent = await manager.getOrCreate<Parent>();
        parent.set(Parent.value1Label, 1);
        await manager.setState(parent);
        var child = await manager.getOrCreateBySpecification<Child>(Parent.toChild, parent.id);
        child.set(Child.value1Label, 1);
        await manager.setState(child, spec: Parent.toChild, fromId: parent.id);

        await db.set(parent.dbReference, parent.data);
        await db.set(child.dbReference, child.data);
        await db.set(manager.relationships.values.first.dbReference, manager.relationships.values.first.data);

        manager.data.clear();
        manager.relationships.clear();
        manager.fromIds.clear();

        var list = await manager.listBySpecification<Child>(Parent.toChild, parent.id);
        expect(list.length, 1);
      });

      test('When I call listBySpecification with a fromId that has two matches I find two matches.', () async {
        var parent = await manager.getOrCreate<Parent>();
        parent.set(Parent.value1Label, 1);
        await manager.setState(parent);
        var child = await manager.getOrCreateBySpecification<Child>(Parent.toChild, parent.id);
        child.set(Child.value1Label, 1);
        await manager.setState(child, spec: Parent.toChild, fromId: parent.id);
        var child2 = Child();
        child2.set(Child.value1Label, 2);
        await manager.setState(child2, spec: Parent.toChild, fromId: parent.id);

        await db.set(parent.dbReference, parent.data);
        await db.set(child.dbReference, child.data);
        await db.set(child2.dbReference, child2.data);
        await db.set(manager.relationships.values.first.dbReference, manager.relationships.values.first.data);
        await db.set(manager.relationships.values.last.dbReference, manager.relationships.values.last.data);

        manager.data.clear();
        manager.relationships.clear();
        manager.fromIds.clear();

        var list = await manager.listBySpecification<Child>(Parent.toChild, parent.id);
        expect(list.length, 2);
      });

      test('When I call listBySpecification with a fromId in the state object two matches I find two matches.', () async {
        var parent = await manager.getOrCreate<Parent>();
        parent.set(Parent.value1Label, 1);
        await manager.setState(parent);
        var child = await manager.getOrCreateBySpecification<Child>(Parent.toChild, parent.id);
        child.set(Child.value1Label, 1);
        await manager.setState(child, spec: Parent.toChild, fromId: parent.id);
        var child2 = Child();
        child2.set(Child.value1Label, 2);
        await manager.setState(child2, spec: Parent.toChild, fromId: parent.id);

        var list = await manager.listBySpecification<Child>(Parent.toChild, parent.id);
        expect(list.length, 2);
      });

      test('When I call listBySpecification with a fromId and a broken link I expect an exception.', () async {
        var parent = await manager.getOrCreate<Parent>();
        parent.set(Parent.value1Label, 1);
        await manager.setState(parent);
        var child = await manager.getOrCreateBySpecification<Child>(Parent.toChild, parent.id);
        child.set(Child.value1Label, 1);
        await manager.setState(child, spec: Parent.toChild, fromId: parent.id);
        var child2 = Child();
        child2.set(Child.value1Label, 2);
        await manager.setState(child2, spec: Parent.toChild, fromId: parent.id);

        await db.set(parent.dbReference, parent.data);
        await db.set(child.dbReference, child.data);
        await db.set(manager.relationships.values.first.dbReference, manager.relationships.values.first.data);
        await db.set(manager.relationships.values.last.dbReference, manager.relationships.values.last.data);

        manager.data.clear();
        manager.relationships.clear();
        manager.fromIds.clear();

        try {
          await manager.listBySpecification<Child>(Parent.toChild, parent.id);
          expect(true, false);
        } catch (ex) {
          expect(ex is DataStateManagerException, true, reason: ex.runtimeType.toString());
        }
      });
    });

    group('Test setState', () {
      test('When I call setState with an object without any relationships I expect it to be stored in the state', () async {
        var parent = await manager.getOrCreate<Parent>();
        parent.set(Parent.value1Label, 1);
        await manager.setState(parent);

        expect(manager.data[parent.id] != null, true);
        expect(manager.data.length, 1);
        expect(manager.relationships.isEmpty, true);
      });

      test('When I call setState to add a relationship object the items is added to the relationships map', () async {
        var rel = Injector.appInstance.get<DataObjectRelationship>();
        await manager.setState(rel);

        expect(manager.relationships[rel.id] != null, true);
        expect(manager.relationships.length, 1);
        expect(manager.data.isEmpty, true);
      });

      test('When I call setState with an object without any relationships and only fromId is provided I expect an exception', () async {
        var parent = await manager.getOrCreate<Parent>();
        parent.set(Parent.value1Label, 1);

        try {
          await manager.setState(Child(), fromId: parent.id);
          expect(true, false);
        } catch (ex) {
          expect(ex is DataStateManagerException, true, reason: ex.runtimeType.toString());
        }
      });

      test('When I call setState with an object without any relationships and only spec is provided I expect an exception', () async {
        var parent = await manager.getOrCreate<Parent>();
        parent.set(Parent.value1Label, 1);

        try {
          await manager.setState(Child(), spec: Parent.toChild);
          expect(true, false);
        } catch (ex) {
          expect(ex is DataStateManagerException, true, reason: ex.runtimeType.toString());
        }
      });

      test('When I call setState with an object and I specify a relationship then the state is updated with the relationships ', () async {
        var parent = await manager.getOrCreate<Parent>();
        var child = Child();
        await manager.setState(parent);
        await manager.setState(child, spec: Parent.toChild, fromId: parent.id);

        expect(manager.relationships.length, 1);
        expect(manager.data.length, 2);
        expect(manager.data.containsKey(parent.id), true);
        expect(manager.data.containsKey(child.id), true);

        var o = manager.relationships.values.first;
        expect(o.fromId, parent.id);
        expect(o.toId, child.id);
        expect(o.fromType, Parent.objectType);
        expect(o.toType, Child.objectType);
        expect(o.relationshipType, Parent.toChild);
      });

      test(
          'When I call setState with an object and I specify a relationship and the relationship is already present then I do not expect the relationships to be updated ',
          () async {
        var parent = await manager.getOrCreate<Parent>();
        var child = Child();
        await manager.setState(parent);
        await manager.setState(child, spec: Parent.toChild, fromId: parent.id);

        var relId = manager.relationships.values.first.id;

        child.set(Child.value1Label, 2);
        await manager.setState(child, spec: Parent.toChild, fromId: parent.id);

        expect(manager.relationships.length, 1);
        expect(manager.data.length, 2);
        expect(manager.data.containsKey(parent.id), true);
        expect(manager.data.containsKey(child.id), true);

        var o = manager.relationships.values.first;
        expect(o.fromId, parent.id);
        expect(o.toId, child.id);
        expect(o.fromType, Parent.objectType);
        expect(o.toType, Child.objectType);
        expect(o.relationshipType, Parent.toChild);
        expect(o.sequence == null, true);

        expect(manager.data[child.id]?.get(Child.value1Label), 2);
        expect(manager.relationships.values.first.id, relId);
      });

      test(
          'When I call setState with an object and I specify a relationship and the relationship is sequenced I expect the sequence numbers to be set ',
              () async {
            var parent = await manager.getOrCreate<Parent>();
            var child = Child();
            await manager.setState(parent);
            await manager.setState(child, spec: Parent.toManyChild, fromId: parent.id);

            var relId = manager.relationships.values.first.id;

            child.set(Child.value1Label, 2);
            await manager.setState(child, spec: Parent.toManyChild, fromId: parent.id);

            expect(manager.relationships.length, 1);
            expect(manager.data.length, 2);
            expect(manager.data.containsKey(parent.id), true);
            expect(manager.data.containsKey(child.id), true);

            var o = manager.relationships.values.first;
            expect(o.fromId, parent.id);
            expect(o.toId, child.id);
            expect(o.fromType, Parent.objectType);
            expect(o.toType, Child.objectType);
            expect(o.relationshipType, Parent.toManyChild);
            expect(o.sequence, 0);

            expect(manager.data[child.id]?.get(Child.value1Label), 2);
            expect(manager.relationships.values.first.id, relId);



            var child2 = Child();
            await manager.setState(child2, spec: Parent.toManyChild, fromId: parent.id);

            expect(manager.relationships.length, 2);
            expect(manager.data.length, 3);
            expect(manager.data.containsKey(parent.id), true);
            expect(manager.data.containsKey(child.id), true);
            expect(manager.data.containsKey(child2.id), true);
            var o2 = manager.relationships.values.last;

            expect(o2.fromId, parent.id);
            expect(o2.toId, child2.id);
            expect(o2.fromType, Parent.objectType);
            expect(o2.toType, Child.objectType);
            expect(o2.relationshipType, Parent.toManyChild);
            expect(o2.sequence, 1);
          });
    });
  });
}

class Parent extends PersistableDataObject {
  static const String toChild = 'parentToChild';
  static const String toManyChild = 'parentToManyChild';

  static const String objectType = 'Parent';

  static const String value1Label = 'value1';

  Parent() : super(objectType);
}

class Child extends PersistableDataObject {
  static const String objectType = 'Child';

  static const String value1Label = 'value1';

  Child() : super(objectType);
}

void registerTestDependencies() {
  Injector.appInstance.registerDependency<Parent>(() => Parent());
  Injector.appInstance.registerDependency<Child>(() => Child());
}

Map<String, RelationshipSpecification> testRelationshipSpecification() {
  var specifications = <String, RelationshipSpecification>{};

  specifications[Parent.toChild] = RelationshipSpecification(Parent.objectType, Child.objectType, Parent.toChild);
  specifications[Parent.toManyChild] = RelationshipSpecification(Parent.objectType, Child.objectType, Parent.toManyChild, isSequenced: true);

  return specifications;
}
