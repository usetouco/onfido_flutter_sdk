import Flutter
import UIKit
import Onfido

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
            
            startFlow(sdkToken: sdkToken, steps: steps, result: result)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func startFlow(sdkToken: String, steps: Array<String>, result: @escaping FlutterResult) {
        let configBuilder = OnfidoConfig.builder()
        
        configBuilder.withSDKToken(sdkToken)

        for step in steps {
            switch step {
            case "welcome":
                configBuilder.withWelcomeStep()
                break;
            case "captureDocument":
                configBuilder.withDocumentStep()
                break;
            case "captureFace":
                configBuilder.withFaceStep(ofVariant: .photo(withConfiguration: nil))
                break;
    //            case "finalScreen":
    //                configBuilder.
            default:
                break;
            }
        }

        let config = try! configBuilder.build()
        
        let onfidoFlow = OnfidoFlow(withConfiguration: config)
            // Callback when flow ends
            .with(responseHandler: { response in
                if case let OnfidoResponse.error(onfidoError) = response {
                    result([
                        "method": "onError",
                        "message": "\(onfidoError)"
                    ])
                 } else if case OnfidoResponse.success = response {
                     result([
                        "method": "onUserCompleted"
                     ])
                 } else if case OnfidoResponse.cancel = response {
                     result([
                        "method": "onUserExited"
                     ])
                 }
            })
        
        let onfidoRun = try! onfidoFlow.run()
        onfidoRun.modalPresentationStyle = .fullScreen
        UIApplication.shared.windows.first?.rootViewController?.present(onfidoRun, animated: true)
    }
}
