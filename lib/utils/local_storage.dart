import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  Future<void> setFirstUserCheck() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstUserCheck', true);
  }

  Future<bool> getFirstUserCheck() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('firstUserCheck') ?? false;
  }

  Future<bool> setReserveBeat(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool('reserveBeat', value);
  }

  Future<bool> getReserveBeat() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('reserveBeat') ?? false;
  }
}
