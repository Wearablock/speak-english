import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:upgrader/upgrader.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'screens/main/main_screen.dart';
import 'screens/onboarding/goal_onboarding_screen.dart';
import 'services/preferences_service.dart';

class SpeakEnglishApp extends StatefulWidget {
  const SpeakEnglishApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);
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
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context)?.appTitle ?? 'Speak English',
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: UpgradeAlert(
                child: const _AppHome(),
              ),
            );
          },
        );
      },
    );
  }
}

class _AppHome extends StatefulWidget {
  const _AppHome();

  @override
  State<_AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<_AppHome> {
  bool _showOnboarding = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  void _checkOnboarding() {
    final isComplete = PreferencesService.isOnboardingComplete();
    setState(() {
      _showOnboarding = !isComplete;
      _initialized = true;
    });
  }

  void _onOnboardingComplete() {
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_showOnboarding) {
      return GoalOnboardingScreen(onComplete: _onOnboardingComplete);
    }

    return const MainScreen();
  }
}
