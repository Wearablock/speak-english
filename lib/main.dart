import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'models/app_language.dart';
import 'services/preferences_service.dart';
import 'services/speech_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  await SpeechService().initialize();

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

  // TODO: Phase 5에서 광고 초기화 추가
  // await AdService.init();

  runApp(const SpeakEnglishApp());
}
