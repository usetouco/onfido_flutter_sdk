#import "OnfidoFlutterSdkPlugin.h"
#if __has_include(<onfido_flutter_sdk/onfido_flutter_sdk-Swift.h>)
#import <onfido_flutter_sdk/onfido_flutter_sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "onfido_flutter_sdk-Swift.h"
#endif

@implementation OnfidoFlutterSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftOnfidoFlutterSdkPlugin registerWithRegistrar:registrar];
}
@end
