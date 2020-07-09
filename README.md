# onfido_flutter_sdk

Flutter wrapper around the official Onfido SDK

## Android
Supports API 20+

Add the following to your `AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```


## iOS
Supports iOS 10+

Add the following permissions to your `Info.plist`
```xml
<key>NSCameraUsageDescription</key>
<string>Required for document and facial capture</string>
<key>NSMicrophoneUsageDescription</key>
<string>Required for video capture</string>
```