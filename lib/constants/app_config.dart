import 'dart:io';

class AppConfig {
  AppConfig._();

  // 앱 정보
  static const String appName = 'Speak English';
  static const String appVersion = '1.1.2';
  static const String appBuildNumber = '7';

  // GitHub 원격 데이터 저장소
  // - 로컬 assets: 최소 fallback 데이터만 유지 (카테고리당 3개)
  // - 전체 레슨 데이터는 이 URL에서 앱 시작 시 자동 동기화
  static const String githubDataBaseUrl =
      'https://raw.githubusercontent.com/Wearablock/speak-english/main/github-data';

  // AdMob 앱 ID (테스트 ID - 배포 전 실제 ID로 교체)
  static String get adMobAppId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544~3347511713'; // 테스트 ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544~1458002511'; // 테스트 ID
    }
    return '';
  }

  // 배너 광고 ID (테스트 ID)
  static String get bannerAdId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return '';
  }

  // 전면 광고 ID (테스트 ID)
  static String get interstitialAdId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    return '';
  }

  // 음성 인식 설정
  static const String speechLocale = 'en-US';
  static const int speechListenDurationSeconds = 30;
  static const int speechPauseDurationSeconds = 3;

  // 진도 설정
  static const double completionThreshold = 0.8; // 80% 이상 완료 처리

  // 광고 표시 간격 (레슨 수)
  static const int adIntervalLessons = 3; // 3개 레슨마다 전면 광고

  // 개발 모드 확인
  static const bool isDebug = bool.fromEnvironment('dart.vm.product') == false;
}
