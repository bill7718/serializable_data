
import 'package:serializable_data/beta/data_object_relationship.dart';
import 'package:serializable_data/serializable_data.dart';
import 'package:test/test.dart';

void main() {
  group('DataObjectRelationship', () {


    setUp(() {

    });

    test('Test base constructor', () {

      var o = DataObjectRelationship();
      expect(o.toId,  null);
      expect(o.type, DataObjectRelationship.objectType);
      expect(o.active, true);
    });

    test('Test .data constructor', () {
      var parent = Parent();
      var child = Child();
      var o = DataObjectRelationship.data(from: parent, to: child, type: 'parentToChild');

      expect(o.type, DataObjectRelationship.objectType);
      expect(o.fromId, parent.id);
      expect(o.fromType, parent.type);
      expect(o.toId, child.id);
      expect(o.toType, child.type);
      expect(o.relationshipType, 'parentToChild');
      expect(o.active, true);

      var o2 = DataObjectRelationship.data(from: parent, to: child, type: 'parentToChild', sequenceNumber: 3);
      expect(o2.sequence, 3);
      expect(o2.active, true);
    });

    //TODO test spec constructor, snapshots and active label

  });
}

class Parent extends PersistableDataObject {
  Parent({Map<String, dynamic>? data}) : super('Parent',  data: data);
}

class Child extends PersistableDataObject {
  Child({Map<String, dynamic>? data}) : super('Child',  data: data);
}