import 'package:hive/hive.dart';
import '../model/local_log.dart';

class LocalLogger {
  final Box<LocalLog> _box = Hive.box<LocalLog>('localLogBox');

  List<LocalLog> getAll() {
    return _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> add(LocalLog log) async {
    await _box.add(log);
  }

  Future<void> deleteAt(int index) async {
    await _box.deleteAt(index);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}