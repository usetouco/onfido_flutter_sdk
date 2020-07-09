import Flutter
import UIKit

public class SwiftOnfidoFlutterSdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "onfido_flutter_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftOnfidoFlutterSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
