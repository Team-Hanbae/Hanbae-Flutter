import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  final AudioPlayer _player = AudioPlayer();

  Future<void> play(String assetPath) async {
    await _player.play(AssetSource(assetPath));
  }
}