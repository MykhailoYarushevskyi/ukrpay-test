import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';

class Auth with ChangeNotifier {
  static const MAIN_TAG = '## Auth';
  // The type [bool] in the [Future<bool>] is using now for test purpose only
  Future<bool> sendCodeToVerify(String code) async {
    log('$MAIN_TAG.sendCodeToVerify code: $code');
    try {
      return await Future.delayed(
          Duration(seconds: 3), () => _verifyCodeForTestCase(code));
    } on Exception catch (error) {
      throw error;
    }
  }

  FutureOr<bool> _verifyCodeForTestCase(code) async {
    if (code == '1111') {
      return true;
    }
    throw Exception('The code is incorrect. Please, enter correct code');
  }
}
