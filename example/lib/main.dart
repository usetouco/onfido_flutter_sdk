import 'dart:async';

import 'package:flutter/material.dart';
import 'package:onfido_flutter_sdk/onfido_flutter_sdk.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<void> startFlow() async {
    await OnfidoFlutterSdk(
      sdkToken:
          "eyJhbGciOiJIUzI1NiJ9.eyJwYXlsb2FkIjoiVVZYaFRtUG10Wmh4WDlaMi9uSVJPbDJtMmpEMkMySmFXTklnRkt1Q2Zpc2pVb1hUVlJ2WTU3T0ZrM3pEXG5SVWRDZDZkeEFvblF1UU05c21GWmhCOTZ6MWtsczFYajA5WFZzV2txeThRMG1KNUlhd292ejJjQzRMc1pcbnBaSFR0QkxnXG4iLCJ1dWlkIjoiSmdxdmxibkRqVHYiLCJleHAiOjE1OTQzODE3MzMsInVybHMiOnsib25maWRvX2FwaV91cmwiOiJodHRwczovL2FwaS5vbmZpZG8uY29tIiwidGVsZXBob255X3VybCI6Imh0dHBzOi8vdGVsZXBob255Lm9uZmlkby5jb20iLCJkZXRlY3RfZG9jdW1lbnRfdXJsIjoiaHR0cHM6Ly9zZGsub25maWRvLmNvbSIsInN5bmNfdXJsIjoiaHR0cHM6Ly9zeW5jLm9uZmlkby5jb20iLCJob3N0ZWRfc2RrX3VybCI6Imh0dHBzOi8vaWQub25maWRvLmNvbSJ9fQ.xGqOA8oI8FB9I7vPye3SVOa0uQFunXpb9D-atwb-6ng",
      onError: (message) {
        print('');
        print('');
        print('');
        print('onError $message');
        print('');
        print('');
        print('');
      },
      onUserCompleted: () {
        print('');
        print('');
        print('');
        print('userCompleted');
        print('');
        print('');
        print('');
      },
      onUserExited: () {
        print('');
        print('');
        print('');
        print('userExited');
        print('');
        print('');
        print('');
      },
    ).startFlow();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: RaisedButton(
            onPressed: startFlow,
            child: Text('Start Onfido Flow'),
          ),
        ),
      ),
    );
  }
}
