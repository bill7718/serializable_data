library show_coverage;

import 'dart:io';

var fullCoverageExpected = <String>{
  'data_object.dart',
  'persistable_data_object.dart',
  'currency.dart',
  'validators.dart',
  'calendar.dart',
  'relationship_specification.dart',
  'data_specification.dart',
  'helper.dart',
  'combined_data_object.dart',
  'database_reader.dart',
  'database_updater.dart',
  'data_list_getter.dart'
};

void main() {
  var codeFiles = <String>{};
  codeFiles.addAll(fullCoverageExpected);

  var file = File('coverage/lcov.info');
  var lines = file.readAsLinesSync();
  var source = '';
  var codeLines = 0;
  var testedLines = 0;

  for (var line in lines) {
    if (line.startsWith('SF:lib')) {
      source = line.split('\\').last;
      codeLines = 0;
      testedLines = 0;
    }

    if (line.startsWith('LF')) {
      codeLines = int.parse(line.split(':').last);
    }

    if (line.startsWith('LH')) {
      testedLines = int.parse(line.split(':').last);

      if (codeLines == testedLines) {
        codeFiles.remove(source);
      }
    }
  }

  if (codeFiles.isEmpty) {
    print('Code Coverage complete');
  } else {
    throw Exception('Code coverage incomplete for ${codeFiles.toString()} ');
  }
}
