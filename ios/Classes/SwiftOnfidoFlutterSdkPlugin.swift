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
            
            let buttonsColor: String? = arguments["buttonsColor"] as? String
            let buttonsPressedColor: String? = arguments["buttonsPressedColor"] as? String
            let buttonsTextColor: String? = arguments["buttonsTextColor"] as? String
            let supportDarkMode: Bool = arguments["iosSupportDarkMode"] as! Bool

            let primaryColor = buttonsColor != nil ? fromHex(hex: buttonsColor!) : UIColor.primaryColor
            let primaryTitleColor = buttonsTextColor != nil ? fromHex(hex: buttonsTextColor!) : UIColor.white
            let primaryBackgroundPressedColor = buttonsPressedColor != nil ? fromHex(hex: buttonsPressedColor!) : UIColor.primaryButtonColorPressed
            
            let appearance = Appearance(
                primaryColor: primaryColor,
                primaryTitleColor: primaryTitleColor,
                primaryBackgroundPressedColor: primaryBackgroundPressedColor,
                supportDarkMode: supportDarkMode
            )

            startFlow(sdkToken: sdkToken, steps: steps, appearance: appearance, result: result)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func startFlow(sdkToken: String, steps: Array<String>, appearance: Appearance, result: @escaping FlutterResult) {
        let configBuilder = OnfidoConfig.builder()
        
        configBuilder
            .withSDKToken(sdkToken)
            .withAppearance(appearance)

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
    
    private func fromHex(hex: String) -> UIColor {
        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)

        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }

        var color: UInt32 = 0
        scanner.scanHexInt32(&color)

        let mask = 0x000000FF
        let redInt = Int(color >> 16) & mask
        let greenInt = Int(color >> 8) & mask
        let blueInt = Int(color) & mask

        let red = CGFloat(redInt) / 255.0
        let green = CGFloat(greenInt) / 255.0
        let blue = CGFloat(blueInt) / 255.0

        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

extension UIColor {

    static var primaryColor: UIColor {
        return decideColor(light: UIColor.from(hex: "#353FF4"), dark: UIColor.from(hex: "#3B43D8"))
    }

    static var primaryButtonColorPressed: UIColor {
        return decideColor(light: UIColor.from(hex: "#232AAD"), dark: UIColor.from(hex: "#5C6CFF"))
    }

    private static func decideColor(light: UIColor, dark: UIColor) -> UIColor {
        #if XCODE11
        guard #available(iOS 13.0, *) else {
            return light
        }
        return UIColor { (collection) -> UIColor in
            return collection.userInterfaceStyle == .dark ? dark : light
        }
        #else
        return light
        #endif
    }

    static func from(hex: String) -> UIColor {

        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)

        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }

        var color: UInt32 = 0
        scanner.scanHexInt32(&color)

        let mask = 0x000000FF
        let redInt = Int(color >> 16) & mask
        let greenInt = Int(color >> 8) & mask
        let blueInt = Int(color) & mask

        let red = CGFloat(redInt) / 255.0
        let green = CGFloat(greenInt) / 255.0
        let blue = CGFloat(blueInt) / 255.0

        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
