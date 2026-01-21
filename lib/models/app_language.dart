import 'package:flutter/material.dart';

class AppLanguage {
  final String code;
  final String name;
  final String nativeName;
  final Locale locale;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.locale,
  });

  static const List<AppLanguage> supportedLanguages = [
    AppLanguage(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      locale: Locale('en'),
    ),
    AppLanguage(
      code: 'ko',
      name: 'Korean',
      nativeName: '한국어',
      locale: Locale('ko'),
    ),
    AppLanguage(
      code: 'ja',
      name: 'Japanese',
      nativeName: '日本語',
      locale: Locale('ja'),
    ),
    AppLanguage(
      code: 'zh',
      name: 'Chinese (Simplified)',
      nativeName: '简体中文',
      locale: Locale('zh'),
    ),
    AppLanguage(
      code: 'zh_TW',
      name: 'Chinese (Traditional)',
      nativeName: '繁體中文',
      locale: Locale.fromSubtags(languageCode: 'zh', countryCode: 'TW'),
    ),
    AppLanguage(
      code: 'es',
      name: 'Spanish',
      nativeName: 'Español',
      locale: Locale('es'),
    ),
    AppLanguage(
      code: 'fr',
      name: 'French',
      nativeName: 'Français',
      locale: Locale('fr'),
    ),
    AppLanguage(
      code: 'de',
      name: 'German',
      nativeName: 'Deutsch',
      locale: Locale('de'),
    ),
    AppLanguage(
      code: 'pt',
      name: 'Portuguese',
      nativeName: 'Português',
      locale: Locale('pt'),
    ),
    AppLanguage(
      code: 'it',
      name: 'Italian',
      nativeName: 'Italiano',
      locale: Locale('it'),
    ),
    AppLanguage(
      code: 'vi',
      name: 'Vietnamese',
      nativeName: 'Tiếng Việt',
      locale: Locale('vi'),
    ),
    AppLanguage(
      code: 'id',
      name: 'Indonesian',
      nativeName: 'Bahasa Indonesia',
      locale: Locale('id'),
    ),
    AppLanguage(
      code: 'th',
      name: 'Thai',
      nativeName: 'ไทย',
      locale: Locale('th'),
    ),
    AppLanguage(
      code: 'ru',
      name: 'Russian',
      nativeName: 'Русский',
      locale: Locale('ru'),
    ),
    AppLanguage(
      code: 'ar',
      name: 'Arabic',
      nativeName: 'العربية',
      locale: Locale('ar'),
    ),
  ];

  static AppLanguage? fromCode(String code) {
    try {
      return supportedLanguages.firstWhere((lang) => lang.code == code);
    } catch (_) {
      return null;
    }
  }

  static AppLanguage? fromLocale(Locale? locale) {
    if (locale == null) return null;
    try {
      // Try exact match first (with country code)
      if (locale.countryCode != null) {
        final exactMatch = supportedLanguages.where(
          (lang) =>
              lang.locale.languageCode == locale.languageCode &&
              lang.locale.countryCode == locale.countryCode,
        );
        if (exactMatch.isNotEmpty) return exactMatch.first;
      }
      // Fall back to language code only
      return supportedLanguages.firstWhere(
        (lang) => lang.locale.languageCode == locale.languageCode,
      );
    } catch (_) {
      return null;
    }
  }
}
