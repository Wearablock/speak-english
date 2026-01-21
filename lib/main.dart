import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';

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

  // TODO: Phase 2에서 서비스 초기화 추가
  // await PreferencesService.init();
  // await SpeechService().initialize();

  // TODO: Phase 5에서 광고 초기화 추가
  // await AdService.init();

  runApp(const SpeakEnglishApp());
}
