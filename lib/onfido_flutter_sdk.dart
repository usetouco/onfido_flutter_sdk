import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

enum FlowStep {
  welcome, //Welcome step with a step summary, Optional
  captureDocument, //Document Capture Step
  captureFace, //Face Capture Step
  finalScreen //Final Screen Step, Optional
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
  final VoidCallback onError;

  // The user has successfully completed the flow,
  // and the captured photos/videos have been uploaded
  final VoidCallback userCompleted;

  // User left the sdk flow without completing it
  final VoidCallback userExited;

  // TODO(luca): add custom color
  OnfidoFlutterSdk({
    @required this.sdkToken,
    this.flowSteps,
    this.onError,
    this.userCompleted,
    this.userExited,
  }) : assert(sdkToken != null && sdkToken.isNotEmpty);

  Future<void> startFlow() async {
    List<FlowStep> steps;

    if (flowSteps == null || flowSteps.isEmpty) {
      steps = [FlowStep.captureDocument, FlowStep.captureFace];
    } else {
      steps = flowSteps;
    }

    final String message = await _channel.invokeMethod(
      'startFlow',
      {
        "sdkToken": sdkToken,
        "flowSteps": steps.map((s) => s.toString().split('.').last).toList(),
      },
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
