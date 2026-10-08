import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PlatformChannelService {
  static const MethodChannel _channel = MethodChannel('vn.edu.vku/device_info');

  /// Fetches battery percentage from Android native layer via MethodChannel
  static Future<int?> getBatteryLevel() async {
    try {
      final int? result = await _channel.invokeMethod<int>('getBatteryLevel');
      return result;
    } on PlatformException catch (e) {
      debugPrint("Failed to get battery level: '${e.message}'.");
      return null;
    } catch (e) {
      debugPrint("MethodChannel error: $e");
      return null;
    }
  }

  /// Fetches native device model name and OS version via MethodChannel
  static Future<String> getDeviceModel() async {
    try {
      final String? result = await _channel.invokeMethod<String>('getDeviceModel');
      return result ?? 'Thiết bị không xác định';
    } on PlatformException catch (e) {
      return 'Ngoại lệ nền tảng: ${e.message}';
    } catch (e) {
      return defaultTargetPlatform.name;
    }
  }
}
