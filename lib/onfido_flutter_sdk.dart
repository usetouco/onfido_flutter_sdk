import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

enum FlowStep {
  welcome, //Welcome step with a step summary, Optional
  captureDocument, //Document Capture Step
  captureFace, //Face Capture Step
  finalScreen //Final Screen Step, Optional and only available on Android
}

class OnfidoFlutterSdk {
  static const MethodChannel _channel = const MethodChannel(
    'onfido_flutter_sdk',
  );

  final String sdkToken;

  // If null or empty defaults to
  // [FlowSteps.captureDocument, FlowSteps.captureFace]
  final List<FlowStep> flowSteps;

  // An exception occurred during the flow
  final Function(String) onError;

  // The user has successfully completed the flow,
  // and the captured photos/videos have been uploaded
  final VoidCallback onUserCompleted;

  // User left the sdk flow without completing it
  final VoidCallback onUserExited;

  final Color buttonsColor;
  final Color buttonsPressedColor;
  final Color buttonsTextColor;
  final bool iosSupportDarkMode;

  /// Theme customizations will only applied to iOS.
  /// Follow the official docs to customise colors on Android.
  OnfidoFlutterSdk({
    @required this.sdkToken,
    this.flowSteps,
    this.onError,
    this.onUserCompleted,
    this.onUserExited,
    this.buttonsColor,
    this.buttonsPressedColor,
    this.buttonsTextColor,
    this.iosSupportDarkMode = false,
  })  : assert(sdkToken != null && sdkToken.isNotEmpty),
        assert(iosSupportDarkMode != null);

  Future<void> startFlow() async {
    List<FlowStep> steps;

    if (flowSteps == null || flowSteps.isEmpty) {
      steps = [
        FlowStep.captureDocument,
        FlowStep.captureFace,
      ];
    } else {
      steps = flowSteps;
    }

    if (!steps.contains(FlowStep.captureDocument) &&
        !steps.contains(FlowStep.captureFace)) {
      onError?.call(
        "At least one of ${FlowStep.captureDocument} "
        "or ${FlowStep.captureFace} must be specified",
      );
      return;
    }

    final response = await _channel.invokeMethod(
      'startFlow',
      {
        "sdkToken": sdkToken,
        "flowSteps": steps.map((s) => s.toString().split('.').last).toList(),
        "buttonsColor": toHexString(buttonsColor),
        "buttonsPressedColor": toHexString(buttonsPressedColor),
        "buttonsTextColor": toHexString(buttonsTextColor),
        "iosSupportDarkMode": iosSupportDarkMode,
      },
    );

    final data = Map<String, dynamic>.from(response);

    final method = data['method'] as String;

    if (method != null) {
      if (method == "onError" && onError != null) {
        onError.call(data['message'] as String);
        return;
      }

      if (method == "onUserCompleted" && onUserCompleted != null) {
        onUserCompleted.call();
        return;
      }

      if (method == "onUserExited" && onUserExited != null) {
        onUserExited.call();
        return;
      }
    }
  }

  String toHexString(Color color) {
    assert(color != null);

    return color.value.toRadixString(16).substring(2, 8);
  }
}
