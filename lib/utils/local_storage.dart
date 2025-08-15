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

  Future<void> setFirstMinimumCheck() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstMinimumCheck', true);
  }

  Future<bool> getFirstMinimumCheck() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('firstMinimumCheck') ?? false;
  }
}
