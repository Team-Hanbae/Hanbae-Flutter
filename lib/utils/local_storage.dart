import 'dart:convert';

import 'package:hanbae/data/basic_jangdan_data.dart';
import 'package:hanbae/model/recent_play_item.dart';
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

  Future<void> setMetronomeOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('metronomeOnboardingSeen', true);
  }

  Future<bool> getMetronomeOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('metronomeOnboardingSeen') ?? false;
  }

  Future<void> setSequenceOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sequenceOnboardingSeen', true);
  }

  Future<bool> getSequenceOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('sequenceOnboardingSeen') ?? false;
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

  Future<List<RecentPlayItem>> getRecentPlayItems() async {
    final prefs = await SharedPreferences.getInstance();
    final rawItems = prefs.getStringList('recentPlayItems');
    if (rawItems != null) {
      return rawItems
          .map((raw) {
            try {
              final decoded = jsonDecode(raw);
              if (decoded is! Map<String, dynamic>) return null;
              return RecentPlayItem.fromJson(decoded);
            } catch (_) {
              return null;
            }
          })
          .whereType<RecentPlayItem>()
          .toList();
    }

    final legacyNames = await getRecentJangdanNames();
    final migrated =
        legacyNames
            .map(
              (name) => RecentPlayItem(
                kind:
                    basicJangdanData.containsKey(name)
                        ? RecentPlayKind.builtin
                        : RecentPlayKind.custom,
                name: name,
              ),
            )
            .toList();
    await setRecentPlayItems(migrated);
    return migrated;
  }

  Future<void> setRecentPlayItems(List<RecentPlayItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'recentPlayItems',
      items.map((item) => jsonEncode(item.toJson())).toList(),
    );
    await setRecentJangdanNames(items.map((item) => item.name).toList());
  }

  Future<void> addRecentJangdan(
    String name, {
    RecentPlayKind kind = RecentPlayKind.custom,
  }) async {
    final recent = await getRecentPlayItems();
    final next = RecentPlayItem(kind: kind, name: name);
    final updated =
        [
          next,
          ...recent.where((e) => e.kind != kind || e.name != name),
        ].take(3).toList();

    await setRecentPlayItems(updated);
  }

  Future<void> removeRecentJangdan(String name, {RecentPlayKind? kind}) async {
    final recent = await getRecentPlayItems();
    final updated =
        recent
            .where((e) => e.name != name || (kind != null && e.kind != kind))
            .toList();
    await setRecentPlayItems(updated);
  }

  // ============================
  // Event / Popup
  // ============================

  /// 오늘 크리스마스 팝업을 보여줘야 하는지 여부를 반환한다.
  /// - 저장된 날짜가 오늘과 같으면 false (보여주지 않음)
  /// - 저장된 날짜가 없거나 오늘이 아니면 true (보여줌)
  Future<bool> shouldShowChristmasPopup(String todayKey) async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString('christmasPopup_dontShowDate');

    if (savedDate == null) return true;

    return savedDate != todayKey;
  }

  /// "오늘 다시 보지 않기"가 체크되었을 때 오늘 날짜를 저장한다.
  /// 체크되지 않았으면 기존 저장 값을 제거한다.
  Future<void> setChristmasPopupDontShowToday(
    bool dontShowToday,
    String todayKey,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    if (dontShowToday) {
      await prefs.setString('christmasPopup_dontShowDate', todayKey);
    } else {
      await prefs.remove('christmasPopup_dontShowDate');
    }
  }
}
