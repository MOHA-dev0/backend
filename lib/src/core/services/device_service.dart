import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static const String _deviceIdKey = 'device_unique_uuid';

  Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? uuid = prefs.getString(_deviceIdKey);

    if (uuid != null) return uuid;

    // Generate accurate device fingerprint if possible, else fallback to UUID
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        // Combine hardware IDs (Note: Android 13+ restricts reading serial/IMEI)
        // We use ID + Model as a base, but generate a persistent UUID for reliability
        uuid = const Uuid().v5(Uuid.NAMESPACE_URL, 'android_id_${androidInfo.id}');
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        // identifierForVendor is reliable for the same developer
        uuid = iosInfo.identifierForVendor ?? const Uuid().v4();
      } else {
        uuid = const Uuid().v4();
      }
    } catch (e) {
      uuid = const Uuid().v4();
    }

    await prefs.setString(_deviceIdKey, uuid);
    return uuid;
  }

  Future<String> getDeviceName() async {
    try {
      if (Platform.isAndroid) {
        final info = await _deviceInfo.androidInfo;
        return '${info.manufacturer} ${info.model}';
      } else if (Platform.isIOS) {
        final info = await _deviceInfo.iosInfo;
        return info.name ?? 'iPhone';
      }
      return 'Unknown Device';
    } catch (e) {
      return 'Generic Device';
    }
  }
}
