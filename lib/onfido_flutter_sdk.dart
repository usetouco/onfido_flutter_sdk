import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class OnfidoFlutterSdk {
  static const MethodChannel _channel =
      const MethodChannel('onfido_flutter_sdk');

  final String sdkToken;
  final VoidCallback onError;
  final VoidCallback userCompleted;
  final VoidCallback userExited;

  // TODO(luca): add steps and custom color
  OnfidoFlutterSdk({
    this.sdkToken,
    this.onError,
    this.userCompleted,
    this.userExited,
  }) : assert(sdkToken != null && sdkToken.isNotEmpty);

  Future<void> startFlow() async {
    final String message = await _channel.invokeMethod(
      'startFlow',
      {"sdkToken": sdkToken},
    );

    if (message != null) {
      if (message == "onError" && onError != null) {
        onError.call();
        return;
      }

      if (message == "userCompleted" && userCompleted != null) {
        userCompleted.call();
        return;
      }

      if (message == "userExited" && userExited != null) {
        userExited.call();
        return;
      }
    }
  }
}
