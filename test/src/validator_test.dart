import 'package:serializable_data/serializable_data.dart';
import 'package:test/test.dart';

void main() {
  group('Test Validators', () {

    setUp(() {
      // Additional setup goes here.
    });
    group('Test validate email', () {
      test('null email is valid', () {
        expect(validateEmail(null), null);
      });

      test('empty email is valid', () {
        expect(validateEmail(''), null);
      });

      test('valid email is valid', () {
        expect(validateEmail('a@b.com'), null);
      });

      test('invalid email is invalid', () {
        expect(validateEmail('ab.com'), genericEmailError);
      });
    });

    group('Test optionalIntegerGTZero', ()
    {
      test('null  is valid', () {
        expect(optionalIntegerGTZero(null), true);
      });

      test('String is invalid', () {
        expect(optionalIntegerGTZero('bb'), false);
      });

      test('Zero is invalid', () {
        expect(optionalIntegerGTZero(0), false);
      });

      test('Minus 1 is invalid', () {
        expect(optionalIntegerGTZero(-1), false);
      });

      test('23.3 is invalid', () {
        expect(optionalIntegerGTZero(23.3), false);
      });

      test('23 is valid', () {
        expect(optionalIntegerGTZero(23), true);
      });
    });

    group('Test mandatoryIntegerGTZero', ()
    {
      test('null  is invalid', () {
        expect(mandatoryIntegerGTZero(null), false);
      });

      test('String is invalid', () {
        expect(mandatoryIntegerGTZero('bb'), false);
      });

      test('Zero is invalid', () {
        expect(mandatoryIntegerGTZero(0), false);
      });

      test('Minus 1 is invalid', () {
        expect(mandatoryIntegerGTZero(-1), false);
      });

      test('23.3 is invalid', () {
        expect(mandatoryIntegerGTZero(23.3), false);
      });

      test('23 is valid', () {
        expect(mandatoryIntegerGTZero(23), true);
      });
    });

    group('Test mandatory', () {
      test('null is invalid', () {
        expect(mandatory(null), false);
      });

      test('String is valid', () {
        expect(mandatory('a@b.com'), true);
      });

      test('integer is valid', () {
        expect(mandatory(42), true);
      });
    });

    group('Test bothPresentOrBothAbsent', () {
      test('both null is valid', () {
        expect(bothPresentOrBothAbsent(null, null), true);
      });

      test('both present is valid', () {
        expect(bothPresentOrBothAbsent(12, 'hello'), true);
      });

      test('first present second absent is invalid', () {
        expect(bothPresentOrBothAbsent(12, null), false);
      });

      test('first absent second present is invalid', () {
        expect(bothPresentOrBothAbsent(null, 999), false);
      });
    });

    group('Test validateCurrencyAmount', ()
    {
      test('12.12 is valid', () {
        expect(validateCurrencyAmount('12.12', 2, '.'), true);
      });

      test('null is valid', () {
        expect(validateCurrencyAmount(null, 2, '.'), true);
      });

      test(' "" is valid', () {
        expect(validateCurrencyAmount('', 2, '.'), true);
      });

      test(' 3.ab is invalid', () {
        expect(validateCurrencyAmount('3.ab', 2, '.'), false);
      });

      test(' 21.21.34 is invalid', () {
        expect(validateCurrencyAmount('21.21.34', 2, '.'), false);
      });
    });

    group('Test validateDDMMYYYY', ()
    {


      test('12/12/2015 is valid', () {
        expect(validateDDMMYYYY('12/12/2015'), true);
      });

      test('null is valid', () {
        expect(validateDDMMYYYY(null), true);
      });

      test(' "" is valid', () {
        expect(validateDDMMYYYY(''), true);
      });

      test('32/12/2015 is invalid', () {
        expect(validateDDMMYYYY('32/12/2015'), false);
      });

      test('31/13/2015 is invalid', () {
        expect(validateDDMMYYYY('31/13/2015'), false);
      });

      test('31/4/2015 is invalid', () {
        expect(validateDDMMYYYY('31/4/2015'), false);
      });

      test('29/2/2015 is invalid', () {
        expect(validateDDMMYYYY('31/4/2015'), false);
      });
    });

    group('Test atLeastOne', () {

      var object = TestDataObject(<String, dynamic>{});

      setUp(() {
        object = TestDataObject(<String, dynamic>{});
      });


      test('both null is invalid', () {
        expect(atLeastOne(object, ['value1', 'value2']), false);
      });

      test('both present is valid', () {
        object.set('value1', 'hi');
        object.set('value2', 'bye');
        expect(atLeastOne(object, ['value1', 'value2']), true);
      });

      test('first present second absent is valid', () {
        object.set('value1', 'hi');
        expect(atLeastOne(object, ['value1', 'value2']), true);
      });

      test('first absent second present is valid', () {
        object.set('value2', 'bye');
        expect(atLeastOne(object, ['value1', 'value2']), true);
      });
    });

  });


  group('Test theSame', () {

    var object = TestDataObject(<String, dynamic>{});

    setUp(() {
      object = TestDataObject(<String, dynamic>{});
    });

    test('zero fields throws an exception', () {
      try {
        theSame(object, []);
        expect(true, false);
      } catch (ex) {
        expect (ex is DataObjectException, true);
      }

    });

    test('one field is valid', () {
      expect(theSame(object, ['value1']), true);
    });

    test('both null is valid', () {
      expect(theSame(object, ['value1', 'value2']), true);
    });

    test('both the same is valid', () {
      object.set('value1', 'hi');
      object.set('value2', 'hi');
      expect(theSame(object, ['value1', 'value2']), true);
    });

    test('first present second absent is invalid', () {
      object.set('value1', 'hi');
      expect(theSame(object, ['value1', 'value2']), false);
    });

    test('first absent second present is invalid', () {
      object.set('value2', 'bye');
      expect(theSame(object, ['value1', 'value2']), false);
    });

    test('both different is invalid', () {
      object.set('value1', 'hi');
      object.set('value2', 'bye');
      expect(theSame(object, ['value1', 'value2']), false);
    });
  });

  group('Test atLeastNCharacters', ()
  {
    test('null is valid', () {
      expect(atLeastNCharacters(null, 6), true);
    });

    test('empty is valid', () {
      expect(atLeastNCharacters(null, 6), true);
    });

    test(' too few characters is invalid', () {
      expect(atLeastNCharacters('123', 6), false);
    });

    test(' exact number of  characters is valid', () {
      expect(atLeastNCharacters('123456', 6), true);
    });

    test(' more  characters is valid', () {
      expect(atLeastNCharacters('1234567', 6), true);
    });

    test(' integers with too few characters are invalid', () {
      expect(atLeastNCharacters(12345, 6), false);
    });

    test(' integers with more  characters is valid', () {
      expect(atLeastNCharacters(1234567, 6), true);
    });
  });

}

class TestDataObject extends DataObject {
  TestDataObject(Map<String, dynamic> data) : super(data);

  @override
  String? validate({List<String>? fields}) {
    if (fields?.contains('brian') ?? false) {
      if (get('brian') == 2700) {
        return 'badBrian';
      }
    }
    return null;
  }
}