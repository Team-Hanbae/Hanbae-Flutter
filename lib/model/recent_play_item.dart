enum RecentPlayKind { builtin, custom, sequence }

class RecentPlayItem {
  final RecentPlayKind kind;
  final String name;

  const RecentPlayItem({required this.kind, required this.name});

  Map<String, dynamic> toJson() => {'kind': kind.name, 'name': name};

  static RecentPlayItem? fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final kindName = json['kind'];
    if (name is! String || kindName is! String) return null;
    final kind =
        RecentPlayKind.values.where((e) => e.name == kindName).firstOrNull;
    if (kind == null) return null;
    return RecentPlayItem(kind: kind, name: name);
  }
}
