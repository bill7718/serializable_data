import 'package:serializable_data/src/data_specification.dart';
import 'package:serializable_data/src/helper.dart';
import '../../lib/src/relationship_specification.dart';
import 'package:test/test.dart';

void main() {
  group('Test methods in DataSpecification', () {

    setUp(() {
      // Additional setup goes here.
    });

    test('create relationship specification', () {

      var d = DataSpecification();

    });

    test('test default validation', () {

      expect(DataSpecification.empty('hello'), null);

    });

    test('test get data from a list', () {

      var specifications = <String, DataSpecification>{};

      var list =  [
        ListEntry('basic', 'Basic', metaData: 'employment'),
        ListEntry('car', 'Car Allowance', metaData: 'employment'),
        ListEntry('pension', 'Pension', metaData: 'other'),
        ListEntry('profit', 'Gross Profit', metaData: 'selfEmployment'),
      ];

      specifications['hi'] = DataSpecification(type: DataSpecification.listType, list: list);

      expect(ListEntry.getDescription('car', list), 'Car Allowance');
      expect(ListEntry.getDescription('car', []), null);

      expect(ListEntry.getMetaData('car', list), 'employment');
      expect(ListEntry.getMetaData('car', []), null);

      expect(DataSpecification.getListDescription('car', 'hi', specifications), 'Car Allowance');

    });
  });
}

