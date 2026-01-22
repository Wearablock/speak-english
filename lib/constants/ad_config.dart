import 'dart:io';
import 'package:flutter/foundation.dart';

class AdConfig {
  AdConfig._();

  /// 광고 활성화 여부
  static bool get adsEnabled => true;

  /// 테스트 모드 (디버그 빌드 시 자동 적용)
  static bool get isTestMode => kDebugMode;

  // ============================================================
  // 배너 광고 ID
  // ============================================================

  static String get bannerAdUnitId {
    if (isTestMode) {
      // 테스트 광고 ID
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716';
    }
    // 실제 광고 ID
    return Platform.isAndroid
        ? 'ca-app-pub-8841058711613546/5833989919' // Android 배너
        : 'ca-app-pub-8841058711613546/6025561605'; // iOS 배너
  }

  // ============================================================
  // 전면 광고 ID
  // ============================================================

  static String get interstitialAdUnitId {
    if (isTestMode) {
      // 테스트 광고 ID
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910';
    }
    // 실제 광고 ID
    return Platform.isAndroid
        ? 'ca-app-pub-8841058711613546/5855021276' // Android 전면
        : 'ca-app-pub-8841058711613546/8831881868'; // iOS 전면
  }

  // ============================================================
  // 전면 광고 설정
  // ============================================================

  /// 전면 광고 최소 간격 (초)
  static const int interstitialMinIntervalSeconds = 60;

  /// 전면 광고 표시 빈도 (N개 레슨마다)
  static const int interstitialFrequencyLessons = 3;
}
