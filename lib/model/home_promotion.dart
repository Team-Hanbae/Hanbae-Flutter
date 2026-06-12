class HomeRemoteConfig {
  final List<HomePromotionBanner> banners;
  final List<HomeAdModal> adModals;

  const HomeRemoteConfig({required this.banners, required this.adModals});
}

class HomePromotionBanner {
  final String id;
  final Uri imageUrl;
  final Uri? linkUrl;

  const HomePromotionBanner({
    required this.id,
    required this.imageUrl,
    this.linkUrl,
  });
}

class HomeAdModal {
  final String id;
  final Uri imageUrl;
  final Uri? linkUrl;

  const HomeAdModal({required this.id, required this.imageUrl, this.linkUrl});
}
