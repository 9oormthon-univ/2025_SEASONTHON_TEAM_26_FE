import 'package:flutter/services.dart';

class KeyHashGenerator {
  static const MethodChannel _channel = MethodChannel('key_hash_generator');

  static Future<String?> getKeyHash() async {
    try {
      final String? keyHash = await _channel.invokeMethod('getKeyHash');
      return keyHash;
    } on PlatformException catch (e) {
      print("Failed to get key hash: '${e.message}'.");
      return null;
    }
  }
}
