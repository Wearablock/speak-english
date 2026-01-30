import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constants/ad_config.dart';
import 'iap_service.dart';

class AdService {
  // 싱글톤 패턴
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;

  // ============================================================
  // 전면 광고
  // ============================================================

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  DateTime? _lastInterstitialShowTime;
  int _completedLessonCount = 0;

  bool get isInterstitialAdReady => _isInterstitialAdReady;

  // ============================================================
  // 초기화
  // ============================================================

  /// AdMob SDK 초기화 (앱 시작 시 한 번 호출)
  Future<void> initialize() async {
    if (_isInitialized) return;
    if (!AdConfig.adsEnabled) return;

    try {
      // iOS ATT 권한 요청
      if (Platform.isIOS) {
        final status =
            await AppTrackingTransparency.trackingAuthorizationStatus;
        if (status == TrackingStatus.notDetermined) {
          await Future.delayed(const Duration(milliseconds: 500));
          await AppTrackingTransparency.requestTrackingAuthorization();
        }
      }

      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('[AdService] 초기화 완료');

      // 전면 광고 미리 로드
      await loadInterstitialAd();
    } catch (e) {
      debugPrint('[AdService] 초기화 실패: $e');
      _isInitialized = false;
    }
  }

  // ============================================================
  // 전면 광고 로드
  // ============================================================

  Future<void> loadInterstitialAd() async {
    if (!AdConfig.adsEnabled) return;

    await InterstitialAd.load(
      adUnitId: AdConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          debugPrint('[AdService] 전면 광고 로드 성공');

          // 광고 닫힘 시 다음 광고 미리 로드
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('[AdService] 전면 광고 닫힘');
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd(); // 다음 광고 로드
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('[AdService] 전면 광고 표시 실패: ${error.message}');
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdReady = false;
          debugPrint('[AdService] 전면 광고 로드 실패: ${error.message}');
        },
      ),
    );
  }

  // ============================================================
  // 전면 광고 표시
  // ============================================================

  /// 전면 광고 표시 (최소 간격 체크 포함)
  Future<bool> showInterstitialAd() async {
    if (!AdConfig.adsEnabled) return false;

    // 프리미엄 사용자는 광고 표시 안함
    if (IAPService().isPremium) {
      debugPrint('[AdService] 프리미엄 사용자 - 전면 광고 스킵');
      return false;
    }

    if (!_isInterstitialAdReady || _interstitialAd == null) {
      debugPrint('[AdService] 전면 광고 준비되지 않음');
      return false;
    }

    // 최소 간격 체크
    if (_lastInterstitialShowTime != null) {
      final elapsed = DateTime.now().difference(_lastInterstitialShowTime!);
      if (elapsed.inSeconds < AdConfig.interstitialMinIntervalSeconds) {
        debugPrint('[AdService] 최소 간격 미충족 (${elapsed.inSeconds}초)');
        return false;
      }
    }

    _lastInterstitialShowTime = DateTime.now();
    _isInterstitialAdReady = false;

    try {
      await _interstitialAd!.show();
      debugPrint('[AdService] 전면 광고 표시');
      return true;
    } catch (e) {
      debugPrint('[AdService] 전면 광고 표시 오류: $e');
      return false;
    }
  }

  // ============================================================
  // 레슨 완료 시 호출 (빈도 기반 전면 광고)
  // ============================================================

  /// 레슨 완료 시 호출 - N개마다 전면 광고 표시
  Future<void> onLessonCompleted() async {
    _completedLessonCount++;
    debugPrint('[AdService] 완료된 레슨: $_completedLessonCount');

    if (_completedLessonCount % AdConfig.interstitialFrequencyLessons == 0) {
      await showInterstitialAd();
    }
  }

  /// 세션 시작 시 카운터 리셋
  void resetLessonCounter() {
    _completedLessonCount = 0;
  }

  // ============================================================
  // 정리
  // ============================================================

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdReady = false;
  }
}
