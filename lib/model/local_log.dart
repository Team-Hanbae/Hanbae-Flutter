import 'package:hanbae/model/jangdan_type.dart';
import 'package:hive/hive.dart';

part 'local_log.g.dart';

@HiveType(typeId: 3)
class LocalLog {
  @HiveField(0)
  final DateTime createdAt;

  @HiveField(1)
  final JangdanType jangdanType;

  @HiveField(2)
  final double? playedTime;

  LocalLog({
    required this.createdAt,
    required this.jangdanType,
    this.playedTime,
  });
}