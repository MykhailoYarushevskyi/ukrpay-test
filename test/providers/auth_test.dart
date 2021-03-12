import 'package:test/test.dart';

import 'package:ukrpay_input_test/providers/auth.dart';

void main() {
  group('App Provider Tests', () {
    var auth = Auth();

    test('The verified code is correct', () async {
      bool result = false;
      try {
        result = await auth.sendCodeToVerify('1111');
        expect(result, true);
      } on Exception catch (e) {
        fail('exception thrown');
      }
    });
    test('The verified code is empty', () async {
      try {
        await auth.sendCodeToVerify('');
        fail("exception not thrown");
      } on Exception catch (e) {
        expect(e, isA<Exception>());
        // expect(
        //     e.toString().trim(), 'The code is incorrect. Please, enter correct code');
      }
    });
    test('The verified code is incorrect', () async {
      try {
        await auth.sendCodeToVerify('9999');
      } on Exception catch (e) {
        expect(e, isA<Exception>());
      }
    });
    test('The verified code is incorrect', () async {
      try {
        await auth.sendCodeToVerify('0000');
      } on Exception catch (e) {
        expect(e, isA<Exception>());
      }
    });
    test('The verified code is incorrect', () async {
      expect(() async {
        return await auth.sendCodeToVerify('1112');
      }, throwsException);
    });
    test('The verified code is longer', () async {
      try {
        await auth.sendCodeToVerify('11111');
      } on Exception catch (e) {
        expect(e, isA<Exception>());
      }
    });
    test('The verified code is shorter', () async {
      // bool result = false;
      try {
        await auth.sendCodeToVerify('111');
      } on Exception catch (e) {
        expect(e, isA<Exception>());
      }
    });
  });
}
