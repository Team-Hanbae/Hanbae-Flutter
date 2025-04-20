import 'package:hive/hive.dart';
import '../model/jangdan.dart';

class JangdanRepository {
  final Box<Jangdan> _box = Hive.box<Jangdan>('customJangdanBox');

  List<Jangdan> getAll() {
    return _box.values.toList();
  }

  Future<void> add(Jangdan jangdan) async {
    if (_box.containsKey(jangdan.name)) {
      throw Exception('같은 이름의 장단이 이미 존재합니다: ${jangdan.name}');
    }
    await _box.put(jangdan.name, jangdan);
  }

  Future<void> update(String key, Jangdan jangdan) async {
    await _box.put(key, jangdan);
  }

  Future<void> delete(String key) async {
    await _box.delete(key);
  }

  bool contains(String key) {
    return _box.containsKey(key);
  }
}