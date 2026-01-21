import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'screens/home/home_screen.dart';

class SpeakEnglishApp extends StatefulWidget {
  const SpeakEnglishApp({super.key});

  // 전역 네비게이터 키
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // 테마 모드 변경을 위한 ValueNotifier
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

  // 로케일 변경을 위한 ValueNotifier
  static final ValueNotifier<Locale?> localeNotifier = ValueNotifier(null);

  @override
  State<SpeakEnglishApp> createState() => _SpeakEnglishAppState();
}

class _SpeakEnglishAppState extends State<SpeakEnglishApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: SpeakEnglishApp.themeNotifier,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<Locale?>(
          valueListenable: SpeakEnglishApp.localeNotifier,
          builder: (context, locale, _) {
            return MaterialApp(
              navigatorKey: SpeakEnglishApp.navigatorKey,
              debugShowCheckedModeBanner: false,

              // 앱 타이틀
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context)?.appTitle ?? 'Speak English',

              // 테마
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,

              // 다국어 지원
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,

              // 홈 화면
              home: const HomeScreen(),
            );
          },
        );
      },
    );
  }
}
