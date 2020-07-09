import 'dart:async';

import 'package:flutter/material.dart';
import 'package:onfido_flutter_sdk/onfido_flutter_sdk.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<void> startFlow() async {
    String message = await OnfidoFlutterSdk(sdkToken: "Test Token").startFlow();
    print(message);
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
