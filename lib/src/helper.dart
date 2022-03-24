
import 'dart:math';
import '../serializable_data.dart';

///
/// Generates an id randomly
///
String generateId({Random? random, int length = 32}) {
  var r = random ?? Random();
  var response = '';
  while (response.length < length) {
    response = response + r.nextInt(9999999).toRadixString(36);
  }
  return response.substring(0, length);
}

///
/// Replace all the values in a String with data from the data objects
///
String parse(String text, List<DataObject> data) {
  var current = text;
  var s = current;

  for (var item in data) {
    s = parseText(s, item);
  }

  // get rid of lines containing text that is not yet parsed properly
  var response = '';
  var lines = s.split('\n');
  for (var line in lines) {
    if (line.contains('{{') && line.contains('}}')) {
      // do nothing
    } else {
      response = response + line + '\n';
    }
  }
  if (response.isEmpty) return response;

  return response.substring(0, response.length - 1);
}


///
/// Replace all the values in a String with data from the data object
///
String parseText(String text, DataObject data ) {

  var current = text;
  var s = parseSingleTextItem(text, data);
  int i = 1;
  while (i < s.length - 4) {
    s = parseSingleTextItem(s, data, start : i);
    while (s != current) {
      current = s;
      s = parseSingleTextItem(s, data, start : i);
    }
    i++;
  }

  return s;
}

///
/// Replace one item in the String with an item in the [DataObject]
///
String parseSingleTextItem(String text, DataObject data, {int start = 0 }) {

  var startIndex = text.indexOf('{{', start);

  if (startIndex == -1) {
    return text;
  }

  var endIndex = text.indexOf('}}', startIndex );

  if (endIndex == -1) {
    return text;
  }

  String from = text.substring(startIndex, endIndex + 2);
  String label = from.substring(2, from.length - 2);
  var to = data.get(label);

  if (to == null) {
    return text;
  } else {
    return text.replaceFirst(from, to);
  }

}



