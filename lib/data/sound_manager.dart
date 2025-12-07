import 'package:flutter/services.dart';
import 'package:hanbae/model/accent.dart';
import 'package:hanbae/model/sound.dart';
import 'dart:developer';

class SoundManager {
  static const MethodChannel _channel = MethodChannel('krabs.hanbae/sound');

  static Future<void> play(Sound sound, Accent accent) async {
    final fileName = '${sound.name}_${accent.name}';
    try {
      await _channel.invokeMethod('play', {'name': fileName});
    } catch (e) {
      log('Error playing sound', error: e);
    }
  }

  static Future<void> preload(Sound sound, Accent accent) async {
    final fileName = '${sound.name}_${accent.name}';
    try {
      await _channel.invokeMethod('preload', {'name': fileName});
    } catch (e) {
      log('Error preloading sound', error: e);
    }
  }

  static Future<void> preloadAllSounds() async {
    final futures = <Future<void>>[];
  
    for (final sound in Sound.values) {
      for (final accent in Accent.values) {
        futures.add(preload(sound, accent));
      }
    }
  
    await Future.wait(futures);
  }
}