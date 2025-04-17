import 'package:audioplayers/audioplayers.dart';
import 'package:hanbae/model/accent.dart';
import 'package:hanbae/model/sound.dart';

class SoundManager {
  final AudioPlayer _player = AudioPlayer()..setPlayerMode(PlayerMode.lowLatency);

  Future<void> play(Sound sound, Accent accent) async {
    await _player.stop(); // Ensure previous sound is stopped
    await _player.play(AssetSource('sounds/${sound.name}_${accent.name}.mp3'));
  }
}