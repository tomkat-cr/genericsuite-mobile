import 'package:flutter/foundation.dart';
import 'utilities.dart';

const platformSvDebug = false;

class AppPlatform {
  // 1. Check if running in a web browser
  static bool get isWeb => kIsWeb;

  // 2. Check if running as a native mobile app
  static bool get isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  // 3. Check for Android
  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  // 4. Check for iOS
  static bool get isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
}

Map<String, String> getPlatformInfo() {
  Map<String, String> result = {
    "platform": "unknown",
    "device_type": "unknown",
  };
  if (AppPlatform.isWeb) {
    if (platformSvDebug) {
      logDebug("PlatformService | checkPlatform | Running in a web browser!");
    }
    result["platform"] = "web";
    result["device_type"] = "browser";
  } else if (AppPlatform.isAndroid) {
    if (platformSvDebug) {
      logDebug("PlatformService | checkPlatform | Running on native Android!");
    }
    result["platform"] = "android";
    result["device_type"] = "mobile";
  } else if (AppPlatform.isIOS) {
    if (platformSvDebug) {
      logDebug("PlatformService | checkPlatform | Running on native iOS!");
    }
    result["platform"] = "ios";
    result["device_type"] = "mobile";
  }

  if (result["device_type"] == "unknown" && AppPlatform.isMobile) {
    if (platformSvDebug) {
      logDebug(
        "PlatformService | checkPlatform | This is a native mobile app (Android or iOS)!",
      );
    }
    result["device_type"] = "mobile";
  }
  return result;
}
