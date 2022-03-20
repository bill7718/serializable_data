import 'package:email_validator/email_validator.dart';
import 'package:serializable_data/beta/generic.dart';
import 'package:serializable_data/src/data_object.dart';

import 'calendar.dart';
import 'currency.dart';
import 'data_specification.dart';

///
/// Returns null if the email provided is null or valid
/// Returns an error code if it is not valid
///
String? validateEmail(String? email) => (email == null || email.isEmpty) ? null : (EmailValidator.validate(email) ? null : genericEmailError);

///
/// Returns true if this is an integer greater than zero
///
///
/// Returns false if this is
/// - null
/// - not an integer
/// - not > 0
///
bool mandatoryIntegerGTZero(dynamic d) => d == null ? false : optionalIntegerGTZero(d);

///
/// Returns true if this is an integer greater than  or it is null
///
///
/// Returns false if this is
/// - not an integer
/// - not > 0
///
bool optionalIntegerGTZero(dynamic d) {
  if (d == null) {
    return true;
  }

  if (d is int) {
    if (d > 0) {
      return true;
    }
    return false;
  } else {
    return false;
  }
}

///
/// Returns true if [d] is not null, false if is it null
///
bool mandatory(dynamic d) => d == null ? false : true;

///
/// Returns true if
/// - both parameters are not null
/// - both parameters are null
///
/// Otherwise returns false
///
bool bothPresentOrBothAbsent(dynamic d, dynamic o) {
  if (o == null && d == null) {
    return true;
  }
  if (o != null && d != null) {
    return true;
  }
  return false;
}

///
/// Checks to see if this value can be converted into an integer using [toAmount]
///
/// Uses [toAmount] to try to convert the value to an integer
/// If [toAmount] throws an exception this method returns false
/// Otherwise it returns true
///
bool validateCurrencyAmount(String? v, int decimalPlaces, String decimalPoint) {
  try {
    toAmount(v, decimalPlaces, decimalPoint);
    return true;
  } catch (ex) {
    return false;
  }
}

///
/// Checks to see if this value can be converted into a DateTime
///
/// Uses [ddmmyyyyToDateTime] to try to convert the value to an DateTime
/// If [ddmmyyyyToDateTime] throws an exception this method returns false
/// Otherwise it returns true
///
bool validateDDMMYYYY(String? date) {
  try {
    ddmmyyyyToDateTime(date);
    return true;
  } catch (ex) {
    return false;
  }
}

///
/// Returns true if at least one of the fields has a non null value
///
/// Returns false otherwise
///
bool atLeastOne(DataObject data, List<String> fields) {
  for (var field in fields) {
    if (mandatory(data.get(field))) {
      return true;
    }
  }
  return false;
}


///
/// Returns true if the fields all have the same value
///
/// Returns false otherwise
///
/// If there is only one field in the list it returns true
/// If there are no fields in the list it throws an exception
///
///
bool theSame(DataObject data, List<String> fields) {

  try {
    var target = data.get(fields.first);

    for (var field in fields) {
      if (data.get(field) != target) {
        return false;
      }
    }
    return true;
  } catch (ex) {
    throw DataObjectException('theSame $fields ${data.data} ${ex.toString()}');
  }
}


///
/// Returns true if the field has at least [length] characters
/// Also returns true if the field is null or empty
///
/// Returns false otherwise
///
bool atLeastNCharacters(dynamic value, int length) {
  var s = value?.toString() ?? '';

  if (s.isEmpty) {
    return true;
  }

  if (s.length < length) {
    return false;
  }

  return true;
}
