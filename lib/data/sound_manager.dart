import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  // final AudioPlayer player = AudioPlayer();

  Future<void> play(String assetPath) async {
    final player = AudioPlayer();
    await player.play(AssetSource(assetPath));
  }
}