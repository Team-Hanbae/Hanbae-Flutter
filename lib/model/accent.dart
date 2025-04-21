import 'package:hive/hive.dart';

part 'accent.g.dart';

@HiveType(typeId: 1)
enum Accent {
  @HiveField(0)
  weak,
  @HiveField(1)
  medium,
  @HiveField(2)
  strong,
  @HiveField(3)
  none,
}