import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../constants/ad_config.dart';
import '../../services/iap_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  Future<void> _loadAd() async {
    if (!AdConfig.adsEnabled) return;
    if (_bannerAd != null) return; // 이미 로드됨

    final width = MediaQuery.of(context).size.width.toInt();

    // Adaptive Banner 사이즈 계산
    final AdSize? adaptiveSize = await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      width,
    );

    final AdSize adSize = adaptiveSize ?? AdSize.banner;

    _bannerAd = BannerAd(
      adUnitId: AdConfig.bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() => _isLoaded = true);
          }
          debugPrint('[BannerAd] 로드 성공: ${adSize.width}x${adSize.height}');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('[BannerAd] 로드 실패: ${error.message}');
        },
      ),
    );

    await _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 광고 비활성화
    if (!AdConfig.adsEnabled) {
      return const SizedBox.shrink();
    }

    // 프리미엄 사용자는 광고 표시 안함
    return ValueListenableBuilder<bool>(
      valueListenable: IAPService().isPremiumNotifier,
      builder: (context, isPremium, child) {
        if (isPremium) {
          return const SizedBox.shrink();
        }

        // 로딩 중 placeholder
        if (!_isLoaded || _bannerAd == null) {
          return const SizedBox(height: 50);
        }

        // 광고 표시
        return Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        );
      },
    );
  }
}
