import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  Future<void> play(String assetPath) async {
    final player = AudioPlayer();
    await player.play(AssetSource(assetPath));
  }
}