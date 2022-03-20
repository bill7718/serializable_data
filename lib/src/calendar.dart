import 'package:serializable_data/serializable_data.dart';

//TODO add validation that date is in the future/past - by a configurable period in the future defaults to zero

///
/// Used to control time and date within the application
///
class Calendar {

  /// The number of milliseconds in a day
  static const int millisecondsPerDay = 24 * 3600 * 1000;

  /// The DateTime object that has a zero value
  static final DateTime baseDate = DateTime.utc(1970, 1, 1);


  ///
  /// The baseline date time for the system
  ///
  /// So if you want the system to behave as if the date is 12/Jan/1980 then pass
  /// that DateTime object into the constructor.
  ///
  late DateTime base;

  ///
  /// The actual [DateTime.now()] when this calendar object was created
  ///
  late DateTime start;

  ///
  /// The difference in milliseconds between the [start] and the [base] [DateTime]
  ///
  late int offset;

  Calendar( {DateTime? base}) {
    this.base = base ?? DateTime.now();
    start = DateTime.now();
    offset = start.millisecondsSinceEpoch - this.base.millisecondsSinceEpoch;
  }

  ///
  /// Returns a DateTime object equal to the actual [DateTime.now()] minus the offset.
  ///
  /// This means that if the system starts on 12/Jan/1980 at midnight then 5 minutes after
  /// the system starts then this method returns 5 minutes past midnight on 12/Jan/1980.
  ///
  DateTime get now {
    var n = DateTime.now();
    return DateTime.fromMillisecondsSinceEpoch(n.millisecondsSinceEpoch - offset);
  }

  ///
  /// Sets the date and time for this calendar
  ///
  ///
  /// Use this to increment the date/time to help with testing.
  ///
  void set( DateTime date) {
    base = date;
    start = DateTime.now();
    offset = start.millisecondsSinceEpoch - base.millisecondsSinceEpoch;
  }
}

/// The [Calendar] object used by this library.
///
/// To override the date/time create a new Calendar object and overwrite this one.
/// ```
/// Calendar christmasDay = Calendar(DateTime(1998, 12, 25));
/// calendar = christmasDay;
/// ```
///
var calendar = Calendar();

/// The number of milliseconds in a day
const int millisecondsPerDay = 24 * 3600 * 1000;

/// Convert an integer number of days since 1970 to a DateTime
DateTime? toDateTime(int? d) {
  if (d != null) {
    return Calendar.baseDate.add(Duration(days: d));
  }
  return null;
}

/// Convert a DateTime to an integer
int? fromDateTime(DateTime? d) {
  if (d == null) {
    return null;
  }

  int t = d.millisecondsSinceEpoch;

  return (t / millisecondsPerDay).round();
}

/// Converts a String in the form 'dd/mm/yyyy' to a [DateTime]
/// Throws an exception if the input is not valid
DateTime? ddmmyyyyToDateTime(String? date ) {
  try {
    if (date == null) {
      return null;
    }

    if (date.isEmpty) {
      return null;
    }

    var split = date.split('/');
    if (split.length != 3) {
      throw(DataObjectException('ddmmyyyyToDateTime $date'));
    }

    var year = int.parse(split.last);
    var month = int.parse(split[1]);
    var day = int.parse(split.first);

    var d = DateTime(year, month, day);
    if (d.year != year || d.month != month || d.day != day) {
      throw(DataObjectException('ddmmyyyyToDateTime $date'));
    }
    return d;

  } catch(ex) {
    throw DataObjectException('Error setting DateTime : $date');
  }

}

/// Convert a [DateTime] to a String in the form 'dd/mm/yyyy'
String? dateTimeToDDMMYYYY(DateTime? date)=>date == null
    ? null
    : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

///
/// Returns true if the from and to dates include today.
/// Null values for from and to are also valid
///
bool isCurrent(int? from, int? to) {
  var now = fromDateTime(calendar.now);
  var current = from == null ? true : from <= now!;
  if (current) {
    current = to == null ? true : now! <= to;
  }
  return current;
}

///
/// Accepts a date as an integer number of days since 1/1/1970
/// and determines if the date is at least 18 years old.
///
///
/// This method uses the [Calendar] object to determine today's date.
///
bool isAtLeast18(int dateOfBirth) {

  DateTime d = toDateTime(dateOfBirth) ?? calendar.now;
  DateTime now = calendar.now;

  if (now.year - 18 > d.year ) {
    return true;
  }
  if (now.year - 18 < d.year ) {
    return false;
  }
  if (now.month > d.month) {
    return true;
  }
  if (now.month < d.month) {
    return false;
  }
  if (now.day >= d.day) {
    return true;
  } else {
    return false;
  }
}


