import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'app.dart';
import 'models/app_language.dart';
import 'services/ad_service.dart';
import 'services/iap_service.dart';
import 'services/lesson_service.dart';
import 'services/preferences_service.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 상태바 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // 화면 방향 고정 (세로만)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 서비스 초기화
  await PreferencesService.init();
  // SpeechService 초기화는 실제 사용 시점(PracticeScreen)으로 지연
  // 스플래시 화면 중 권한 팝업이 가려지는 문제 방지

  // 저장된 언어 설정 로드
  final savedLanguage = PreferencesService.getLanguage();
  if (savedLanguage != null) {
    final lang = AppLanguage.fromCode(savedLanguage);
    if (lang != null) {
      SpeakEnglishApp.localeNotifier.value = lang.locale;
    }
  }

  // 저장된 테마 설정 로드
  final savedTheme = PreferencesService.getThemeMode();
  switch (savedTheme) {
    case 'light':
      SpeakEnglishApp.themeNotifier.value = ThemeMode.light;
      break;
    case 'dark':
      SpeakEnglishApp.themeNotifier.value = ThemeMode.dark;
      break;
    default:
      SpeakEnglishApp.themeNotifier.value = ThemeMode.system;
  }

  // AdMob 초기화
  await AdService().initialize();

  // IAP 초기화
  await IAPService().initialize();

  // 스플래시 화면 제거
  FlutterNativeSplash.remove();

  // 백그라운드에서 레슨 데이터 동기화
  _syncLessonData();

  runApp(const SpeakEnglishApp());
}

/// 백그라운드에서 레슨 데이터 동기화
void _syncLessonData() {
  Future.microtask(() async {
    final result = await LessonService().syncFromRemote();
    debugPrint('Lesson sync: ${result.status.name}');
    if (result.status == SyncStatus.completed) {
      debugPrint('Updated to v${result.newVersion} (${result.newLessonCount} lessons)');
    } else if (result.status == SyncStatus.failed) {
      debugPrint('Sync error: ${result.errorMessage}');
    }
  });
}
