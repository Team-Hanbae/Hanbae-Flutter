import 'package:hive/hive.dart';
import 'package:hanbae/model/jangdan_sequence.dart';

class JangdanSequenceRepository {
  final Box<JangdanSequence> _box = Hive.box<JangdanSequence>(
    'jangdanSequenceBox',
  );

  List<JangdanSequence> getAll() {
    return _box.values.toList();
  }

  JangdanSequence? get(String key) {
    return _box.get(key);
  }

  Future<void> add(JangdanSequence sequence) async {
    final name = sequence.name.trim();
    if (name.isEmpty) {
      throw Exception('장단 이름을 입력해주세요.');
    }
    if (sequence.items.length < 2) {
      throw Exception('장단을 2개 이상 선택해주세요.');
    }
    if (_box.containsKey(name)) {
      throw Exception('같은 이름의 장단이 이미 존재합니다: $name');
    }
    await _box.put(name, sequence.copyWith(name: name));
  }

  Future<void> update(String key, JangdanSequence sequence) async {
    final name = sequence.name.trim();
    if (name.isEmpty) {
      throw Exception('장단 이름을 입력해주세요.');
    }
    if (key != name && _box.containsKey(name)) {
      throw Exception('같은 이름의 장단이 이미 존재합니다: $name');
    }
    if (key != name) {
      await _box.delete(key);
    }
    await _box.put(name, sequence.copyWith(name: name));
  }

  Future<void> delete(String key) async {
    await _box.delete(key);
  }

  bool contains(String key) {
    return _box.containsKey(key);
  }
}
