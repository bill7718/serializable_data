import 'package:serializable_data/serializable_data.dart';
import 'package:test/test.dart';

void main() {
  group('Test Currency', () {
    group('Test toDecimal', () {
      test('Test toDecimal', () {
        expect(toDecimal(null, 2, '.'), null);
        expect(toDecimal(0, 2, '.'), '0.00');
        expect(toDecimal(0, 1, '.'), '0.0');

        expect(toDecimal(1, 2, '.'), '0.01');
        expect(toDecimal(11, 2, '.'), '0.11');
        expect(toDecimal(121, 2, '.'), '1.21');

        expect(toDecimal(381134, 2, '.'), '3811.34');
      });
    });

    group('Test toAmount', () {
      test('12.12 is 1212', () {
        expect(toAmount('12.12', 2, '.'), 1212);
      });

      test('12.12 is 12120 with 3 decimal places', () {
        expect(toAmount('12.12', 3, '.'), 12120);
      });

      test('12,12 is 1212 with decimal comma', () {
        expect(toAmount('12,12', 2, ','), 1212);
      });

      test('12 is 1200', () {
        expect(toAmount('12.12', 2, '.'), 1212);
      });

      test('null is null', () {
        expect(toAmount(null, 2, '.'), null);
      });

      test(' "" is null', () {
        expect(toAmount('', 2, '.'), null);
      });

      test(' 0 is 0', () {
        expect(toAmount('0', 2, '.'), 0);
      });

      test('12.12.34 throws an exception', () {
        try {
          expect(toAmount('12.12.34', 2, '.'), 12120);
          expect(true, false);
        } catch (ex) {
          expect(ex.toString().contains('12.12.34'), true);
        }
      });

      test('ab throws an exception', () {
        try {
          expect(toAmount('ab', 2, '.'), 12120);
          expect(true, false);
        } catch (ex) {
          expect(ex.toString().contains('ab'), true);
        }
      });

      test('ab.3 throws an exception', () {
        try {
          expect(toAmount('ab.3', 2, '.'), 12120);
          expect(true, false);
        } catch (ex) {
          expect(ex.toString().contains('ab.3'), true);
        }
      });

      test('3.ab throws an exception', () {
        try {
          expect(toAmount('3.ab', 2, '.'), 12120);
          expect(true, false);
        } catch (ex) {
          expect(ex.toString().contains('3.ab'), true);
        }
      });
    });
  });
}
