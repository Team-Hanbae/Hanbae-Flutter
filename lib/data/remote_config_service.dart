import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:hanbae/model/home_promotion.dart';

class RemoteConfigService {
  RemoteConfigService({FirebaseRemoteConfig? remoteConfig})
    : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  static const _homeBannersKey = 'home_banners';
  static const _homeAdModalsKey = 'home_ad_modals';

  final FirebaseRemoteConfig _remoteConfig;
  bool _configured = false;

  Future<HomeRemoteConfig> fetchHomePromotions() async {
    await _ensureConfigured();

    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint(e.toString());
    }

    return HomeRemoteConfig(
      banners: _parseBanners(_remoteConfig.getString(_homeBannersKey)),
      adModals: _parseAdModals(_remoteConfig.getString(_homeAdModalsKey)),
    );
  }

  Future<void> _ensureConfigured() async {
    if (_configured) return;

    const appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
    final isProd = appEnv == 'prod' && !kDebugMode;

    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: isProd ? const Duration(hours: 1) : Duration.zero,
      ),
    );
    await _remoteConfig.setDefaults(const {
      _homeBannersKey: '[]',
      _homeAdModalsKey: '[]',
    });

    _configured = true;
  }

  List<HomePromotionBanner> _parseBanners(String rawJson) {
    return _decodeItems(
      rawJson,
    ).map(_bannerFromJson).whereType<HomePromotionBanner>().toList();
  }

  List<HomeAdModal> _parseAdModals(String rawJson) {
    return _decodeItems(
      rawJson,
    ).map(_adModalFromJson).whereType<HomeAdModal>().toList();
  }

  List<Map<String, dynamic>> _decodeItems(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! List) return const [];
      return decoded.whereType<Map>().map((item) {
        return item.map((key, value) => MapEntry(key.toString(), value));
      }).toList();
    } catch (e) {
      debugPrint(e.toString());
      return const [];
    }
  }

  HomePromotionBanner? _bannerFromJson(Map<String, dynamic> json) {
    final parsed = _parsePromotionItem(json);
    if (parsed == null) return null;
    return HomePromotionBanner(
      id: parsed.id,
      imageUrl: parsed.imageUrl,
      linkUrl: parsed.linkUrl,
    );
  }

  HomeAdModal? _adModalFromJson(Map<String, dynamic> json) {
    final parsed = _parsePromotionItem(json);
    if (parsed == null) return null;
    return HomeAdModal(
      id: parsed.id,
      imageUrl: parsed.imageUrl,
      linkUrl: parsed.linkUrl,
    );
  }

  _PromotionItem? _parsePromotionItem(Map<String, dynamic> json) {
    if (json['enabled'] != true) return null;

    final id = json['id'];
    final imageUrl = json['image_url'];
    if (id is! String || id.trim().isEmpty) return null;
    if (imageUrl is! String) return null;

    final parsedImageUrl = _parseHttpsUri(imageUrl);
    if (parsedImageUrl == null) return null;

    final linkUrl = json['link_url'];
    return _PromotionItem(
      id: id.trim(),
      imageUrl: parsedImageUrl,
      linkUrl: linkUrl is String ? _parseOptionalHttpsUri(linkUrl) : null,
    );
  }

  Uri? _parseOptionalHttpsUri(String value) {
    if (value.trim().isEmpty) return null;
    return _parseHttpsUri(value);
  }

  Uri? _parseHttpsUri(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return null;
    return uri;
  }
}

class _PromotionItem {
  final String id;
  final Uri imageUrl;
  final Uri? linkUrl;

  const _PromotionItem({
    required this.id,
    required this.imageUrl,
    this.linkUrl,
  });
}

final remoteConfigService = RemoteConfigService();
