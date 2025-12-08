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

  Future<void> setRecentJangdanNames(List<String> names) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recentJangdanNames', names);
  }

  Future<List<String>> getRecentJangdanNames() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('recentJangdanNames') ?? [];
  }

  Future<void> addRecentJangdan(String name) async {
    final recent = await getRecentJangdanNames();

    // 중복 제거 + 가장 앞에 삽입
    final updated = [name, ...recent.where((e) => e != name)];

    // 최대 3개까지만 유지
    await setRecentJangdanNames(updated);
  }
  
  Future<void> removeRecentJangdan(String name) async {
    final recent = await getRecentJangdanNames();
    final updated = recent.where((e) => e != name).toList();
    await setRecentJangdanNames(updated);
  }
}
