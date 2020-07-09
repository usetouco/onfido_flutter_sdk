import 'dart:async';

import 'package:flutter/services.dart';

class OnfidoFlutterSdk {
  static const MethodChannel _channel =
      const MethodChannel('onfido_flutter_sdk');

  final String sdkToken;

  OnfidoFlutterSdk({this.sdkToken})
      : assert(sdkToken != null && sdkToken.isNotEmpty);

  Future<String> startFlow() async {
    final String message = await _channel.invokeMethod(
      'startFlow',
      {
        "sdkToken": sdkToken,
      },
    );
    return message;
  }
}
