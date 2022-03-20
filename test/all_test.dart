import 'src/validator_test.dart' as validator;
import 'src/calendar_test.dart' as calendar;
import 'src/currency_test.dart' as currency;
import 'src/data_object_test.dart' as data_object;
import 'src/helper_test.dart' as helper;
import 'src/persistable_data_object_test.dart' as persistable;
import 'src/relationship_specification_test.dart' as relationship;
import 'src/data_specification_test.dart' as data_spec;
import 'src/database_reader_test.dart' as reader;
import 'src/database_updater_test.dart' as updater;
import 'src/combined_data_object_test.dart' as combined;
import 'src/data_list_getter_test.dart' as data_getter;

import 'beta/data_state_manager_test.dart' as manager;

main() {
  validator.main();
  calendar.main();
  currency.main();
  data_object.main();
  helper.main();
  persistable.main();
  relationship.main();
  data_spec.main();
  combined.main();
  reader.main();
  updater.main();
  data_getter.main();

  //manager.main();
}