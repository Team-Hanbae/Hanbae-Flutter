import 'package:shared_preferences/shared_preferences.dart';
import '../model/sound.dart';

class SoundPreferences {
  static const _key = 'selected_sound';

  static Future<void> save(Sound sound) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, sound.name);
  }

  static Future<Sound> load() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_key);
    return Sound.values.firstWhere(
      (s) => s.name == name,
      orElse: () => Sound.clave,
    );
  }
}
