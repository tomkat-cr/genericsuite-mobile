import 'dart:io';

import 'package:android_id/android_id.dart'; // Import if using android_id package
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import 'locator_service.dart';

class DeviceIdService {
  static const _storageKey = 'app_device_id';
  static final _storage = storageLocator<FlutterSecureStorage>();
  static final _deviceInfo = DeviceInfoPlugin();
  static final _uuid = Uuid();

  static Future<String> getDeviceId() async {
    // 1. Return cached ID if it exists
    final cachedId = await _storage.read(key: _storageKey);
    if (cachedId != null && cachedId.isNotEmpty) {
      return cachedId;
    }

    String? deviceId;

    // 2. Try platform-specific IDs
    try {
      if (Platform.isAndroid) {
        // Use android_id package for safer access
        final androidIdPlugin = const AndroidId();
        deviceId = await androidIdPlugin.getId();
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor; // ID unique to vendor on iOS
      }
    } catch (_) {
      // Handle potential errors, fall through to fallback
    }

    // 3. Generate and cache a UUID fallback if platform ID is unavailable
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = _uuid.v4();
    }

    // Store the obtained or generated ID securely
    await _storage.write(key: _storageKey, value: deviceId);
    return deviceId;
  }
}

/*
// You can call the getDeviceId method in your app's initialization or wherever you need the unique ID.

import 'package:genericsuite/services/deviceid_service.dart';

String? deviceId = await DeviceIdService.getDeviceId();
print("Device ID: $deviceId");
*/
