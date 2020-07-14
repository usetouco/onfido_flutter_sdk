import Flutter
import UIKit
//import Onfido

public class SwiftOnfidoFlutterSdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "onfido_flutter_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftOnfidoFlutterSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.addApplicationDelegate(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let arguments: Dictionary<String, Any> = call.arguments as! Dictionary
    
    if (call.method == "startFlow") {
        let sdkToken: String = arguments["sdkToken"] as! String
        let steps: Array<String> = arguments["flowSteps"] as! Array<String>
        
        startFlow(sdkToken: sdkToken, steps: steps)
    } else {
        result(FlutterMethodNotImplemented)
    }
  }
    
    private func startFlow(sdkToken: String, steps: Array<String>) {
//        let configBuilder = OnfidoConfig.builder()
//            .withSDKToken("YOUR_SDK_TOKEN_HERE")
//
//        for step in steps {
//            switch step {
//            case "welcome":
//                configBuilder.withWelcomeStep()
//            case "captureDocument":
//                configBuilder.withDocumentStep()
//            case "captureFace":
//                configBuilder.withFaceStep(ofVariant: .photo(withConfiguration: nil))
//            case "finalScreen":
//                configBuilder...
//            default:
//                // do nothing
//            }
//        }
//
//        let config = configBuilder.build()
    }
}
