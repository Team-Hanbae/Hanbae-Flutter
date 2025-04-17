import 'package:flutter/services.dart';
import 'package:hanbae/model/accent.dart';
import 'package:hanbae/model/sound.dart';

class SoundManager {
  static const MethodChannel _channel = MethodChannel('krabs.hanbae/sound');

  static Future<void> play(Sound sound, Accent accent) async {
    final fileName = '${sound.name}_${accent.name}';
    try {
      await _channel.invokeMethod('play', {'name': fileName});
    } catch (e) {
      print('Error playing sound: $e');
    }
  }
}