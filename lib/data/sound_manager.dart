import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  final AudioPlayer _player = AudioPlayer()..setPlayerMode(PlayerMode.lowLatency);

  Future<void> play(String assetPath) async {
    await _player.stop(); // Ensure previous sound is stopped
    await _player.play(AssetSource(assetPath));
  }
}