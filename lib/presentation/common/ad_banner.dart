import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class FixedBannerAd extends StatefulWidget {
  final String adUnitId;

  const FixedBannerAd({super.key, required this.adUnitId});

  @override
  State<FixedBannerAd> createState() => _FixedBannerAdState();
}

class _FixedBannerAdState extends State<FixedBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bannerAd = _bannerAd;
    return SizedBox(
      height: 50,
      child:
          _isLoaded && bannerAd != null
              ? Center(
                child: SizedBox(
                  width: bannerAd.size.width.toDouble(),
                  height: bannerAd.size.height.toDouble(),
                  child: AdWidget(ad: bannerAd),
                ),
              )
              : const SizedBox.shrink(),
    );
  }
}
