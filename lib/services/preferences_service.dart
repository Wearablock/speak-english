import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static SharedPreferences? _prefs;

  // 키 상수
  static const String _keyLocale = 'locale';
  static const String _keyLanguage = 'app_language';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyAdFree = 'ad_free';

  /// 앱 시작 시 초기화
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Locale
  static String? getLocale() => _prefs?.getString(_keyLocale);
  static Future<void> setLocale(String locale) async {
    await _prefs?.setString(_keyLocale, locale);
  }

  // Language
  static String? getLanguage() => _prefs?.getString(_keyLanguage);
  static Future<void> setLanguage(String languageCode) async {
    await _prefs?.setString(_keyLanguage, languageCode);
  }

  // Theme
  static String getThemeMode() => _prefs?.getString(_keyThemeMode) ?? 'system';
  static Future<void> setThemeMode(String mode) async {
    await _prefs?.setString(_keyThemeMode, mode);
  }

  // Onboarding
  static bool isOnboardingComplete() =>
      _prefs?.getBool(_keyOnboardingComplete) ?? false;
  static Future<void> setOnboardingComplete(bool value) async {
    await _prefs?.setBool(_keyOnboardingComplete, value);
  }

  // Ad-Free (IAP용)
  static bool isAdFree() => _prefs?.getBool(_keyAdFree) ?? false;
  static Future<void> setAdFree(bool value) async {
    await _prefs?.setBool(_keyAdFree, value);
  }
}
