
import 'dart:math';

///
/// Convert an integer to a String based on the number of decimal places and decimal
/// point value
///
/// e.g.
///
/// `toDecimal(211, 2, '.')` => '2.11'
///
String? toDecimal(int? v, int decimalPlaces, String decimalPoint) {
  if (v == null) {
    return null;
  }
  var s = v.toString().padLeft(decimalPlaces, '0');

  if (s.length == decimalPlaces) {
    return '0' + decimalPoint + s;
  }

  return s.substring(0, s.length - decimalPlaces) + decimalPoint + s.substring(s.length - decimalPlaces);
}


///
/// Converts a String which represents a decimal value with the number of decimal places and decimal point
/// provided
///
/// Throws an exception if it cannot perform the conversion.
///
int? toAmount(String? v, int decimalPlaces, String decimalPoint) {
  try {
    if (v == null) {
      return null;
    }
    if (v.isEmpty) {
      return null;
    }

    List<String> l = v.split(decimalPoint);
    while (l.length < 2) {
      l.add('0');
    }

    if (l.length > 2) {
      throw Exception('Invalid currency amount $v');
    }

    int amount = int.parse(l.first) * pow(10, decimalPlaces) as int;
    amount = amount + int.parse(l.last.padRight(decimalPlaces, '0'));
    return amount;
  } catch (ex) {
    throw Exception('Invalid currency amount $v');
  }
}
