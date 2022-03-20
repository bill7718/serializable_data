import 'package:serializable_data/src/helper.dart';
import '../../lib/src/relationship_specification.dart';
import 'package:test/test.dart';

void main() {
  group('Test methods in RelationshipSpecification', () {

    setUp(() {
      // Additional setup goes here.
    });

    test('create relationship specification', () {

      var r = RelationshipSpecification('Parent', 'Child', 'parentToChild');

    });
  });
}

