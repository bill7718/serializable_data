import 'package:serializable_data/serializable_data.dart';
import 'package:test/test.dart';

void main() {
  group('Test Calendar', () {

    group('Test Calendar object', () {
      test('Test Calendar now', () {
        var c = Calendar(base: DateTime(2020, 11, 21));
        expect(c.now.year, 2020);
        expect(c.now.month, 11);
        expect(c.now.day, 21);
      });

      test('Test setting the Calendar', () {
        var c = Calendar(base: DateTime(2020, 11, 21));
        expect(c.now.year, 2020);
        expect(c.now.month, 11);
        expect(c.now.day, 21);

        c.set(DateTime(2021, 9, 15));
        expect(c.now.year, 2021);
        expect(c.now.month, 9);
        expect(c.now.day, 15);
      });
    });

    group('Test Covert day number to DateTime', () {

      test('Test Covert day number to DateTime', () {
        expect(toDateTime(null), null);
        expect(toDateTime(0)?.year, 1970);
        expect(toDateTime(0)?.month, 1);
        expect(toDateTime(0)?.day, 1);

        expect(toDateTime(365)?.year, 1971);
        expect(toDateTime(365)?.month, 1);
        expect(toDateTime(365)?.day, 1);

      });

    });

    group('Test fromDateTime', () {

      test('Test fromDateTime', () {
        expect(fromDateTime(null), null);
        expect(fromDateTime(toDateTime(0)), 0);
        expect(fromDateTime(toDateTime(365)), 365);
      });

    });

    group('Test ddmmyyyyToDateTime', ()
    {
      test('12/12/2015 is handled correctly', () {
        expect(ddmmyyyyToDateTime('12/12/2015')?.day, 12);
        expect(ddmmyyyyToDateTime('12/12/2015')?.month, 12);
        expect(ddmmyyyyToDateTime('12/12/2015')?.year, 2015);
      });

      test('null is null', () {
        expect(ddmmyyyyToDateTime(null), null);
      });

      test(' "" is null', () {
        expect(ddmmyyyyToDateTime(''), null);
      });

      test('32/12/2015 throws an exception', () {
        try {
          ddmmyyyyToDateTime('32/12/2015');
          expect(true, false);
        } catch (ex) {
          expect(true, true);
        }
      });

      test('31/13/2015 throws an exception', () {
        try {
          ddmmyyyyToDateTime('31/13/2015');
          expect(true, false);
        } catch (ex) {
          expect(true, true);
        }
      });

      test('31/4/2015 throws an exception', () {
        try {
          ddmmyyyyToDateTime('31/4/2015');
          expect(true, false);
        } catch (ex) {
          expect(true, true);
        }
      });

      test('29/2/2015 throws an exception', () {
        try {
          ddmmyyyyToDateTime('31/4/2015');
          expect(true, false);
        } catch (ex) {
          expect(true, true);
        }
      });

      test('12/12 throws an exception', () {
        try {
          ddmmyyyyToDateTime('12/12');
          expect(true, false);
        } catch (ex) {
          expect(ex is DataObjectException, true);
        }

      });

    });

    group('Test dateTimeToDDMMYYYY', () {

      test('Test dateTimeToDDMMYYYY', () {
        expect(dateTimeToDDMMYYYY(null), null);
        expect(dateTimeToDDMMYYYY(DateTime(2015, 3, 4)), '04/03/2015');
        expect(dateTimeToDDMMYYYY(DateTime(2015, 11, 14)), '14/11/2015');

      });

    });

    group('Test isCurrent', () {

      test('Test isCurrent', () {
        expect(isCurrent(null, null), true);
        expect(isCurrent(100, null), true);
        expect(isCurrent(99999, null), false);
        expect(isCurrent(99999, 999999), false);
        expect(isCurrent(null, 999999), true);
        expect(isCurrent(null, 18900), false);
        expect(isCurrent(100, 21000), true);
      });

    });

    group('Test isAtLeast18', () {

      test('Test isAtLeast18', () {

        var c = Calendar(base: DateTime(2020, 11, 21));
        calendar = c;

        var i = fromDateTime(DateTime(2002, 11, 21))!;
        expect(isAtLeast18(i), true);

        i = fromDateTime(DateTime(2002, 11, 22))!;
        expect(isAtLeast18(i), false);

      });

    });
  });
}

