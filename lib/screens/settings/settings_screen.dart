import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../l10n/app_localizations.dart';
import '../../constants/app_config.dart';
import '../../constants/app_urls.dart';
import '../../models/app_language.dart';
import '../../services/preferences_service.dart';
import '../../app.dart';
import 'webview_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _themeMode = 'system';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _themeMode = PreferencesService.getThemeMode();
    });
  }

  void _setThemeMode(String mode) async {
    await PreferencesService.setThemeMode(mode);
    setState(() => _themeMode = mode);

    switch (mode) {
      case 'light':
        SpeakEnglishApp.themeNotifier.value = ThemeMode.light;
        break;
      case 'dark':
        SpeakEnglishApp.themeNotifier.value = ThemeMode.dark;
        break;
      default:
        SpeakEnglishApp.themeNotifier.value = ThemeMode.system;
    }
  }

  String _getCurrentLanguageName() {
    final currentLocale = SpeakEnglishApp.localeNotifier.value;
    if (currentLocale == null) {
      // System default
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      final lang = AppLanguage.fromLocale(systemLocale);
      return lang?.nativeName ?? 'System';
    }

    final lang = AppLanguage.fromLocale(currentLocale);
    return lang?.nativeName ?? currentLocale.languageCode;
  }

  void _setLanguage(AppLanguage lang) async {
    await PreferencesService.setLanguage(lang.code);
    SpeakEnglishApp.localeNotifier.value = lang.locale;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          // 테마 설정
          ListTile(
            leading: Icon(PhosphorIcons.palette(PhosphorIconsStyle.regular)),
            title: Text(l10n.theme),
            subtitle: Text(_getThemeLabel(l10n)),
            trailing: Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold)),
            onTap: () => _showThemeDialog(context, l10n),
          ),
          const Divider(),

          // 언어 설정
          ListTile(
            leading: Icon(PhosphorIcons.globe(PhosphorIconsStyle.regular)),
            title: Text(l10n.language),
            subtitle: Text(_getCurrentLanguageName()),
            trailing: Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold)),
            onTap: () => _showLanguageDialog(context, l10n),
          ),
          const Divider(),

          // TODO: v1.0.1에서 광고 제거 IAP 추가
          // ListTile(
          //   leading: Icon(PhosphorIcons.crown(PhosphorIconsStyle.regular)),
          //   title: Text(l10n.removeAds),
          //   trailing: Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold)),
          //   onTap: () {
          //     // IAP 구현
          //   },
          // ),
          // const Divider(),

          // 약관 및 정책 섹션
          _buildSectionHeader(context, l10n.termsAndPolicies),

          ListTile(
            leading: Icon(PhosphorIcons.fileText(PhosphorIconsStyle.regular)),
            title: Text(l10n.termsOfService),
            trailing: Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold)),
            onTap: () => _openWebView(context, l10n.termsOfService, AppUrls.termsUrl),
          ),
          const Divider(),

          ListTile(
            leading: Icon(PhosphorIcons.shieldCheck(PhosphorIconsStyle.regular)),
            title: Text(l10n.privacyPolicy),
            trailing: Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold)),
            onTap: () => _openWebView(context, l10n.privacyPolicy, AppUrls.privacyUrl),
          ),
          const Divider(),

          ListTile(
            leading: Icon(PhosphorIcons.headset(PhosphorIconsStyle.regular)),
            title: Text(l10n.support),
            trailing: Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold)),
            onTap: () => _openWebView(context, l10n.support, AppUrls.supportUrl),
          ),
          const Divider(),

          // 앱 정보
          ListTile(
            leading: Icon(PhosphorIcons.info(PhosphorIconsStyle.regular)),
            title: Text(l10n.about),
            subtitle: Text('${l10n.version} ${AppConfig.appVersion}'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  void _openWebView(BuildContext context, String title, String url) {
    final currentLocale = SpeakEnglishApp.localeNotifier.value;
    String htmlLangCode;

    if (currentLocale != null) {
      // zh_TW 특별 처리
      if (currentLocale.countryCode == 'TW') {
        htmlLangCode = 'zh-TW';
      } else {
        htmlLangCode = currentLocale.languageCode;
      }
    } else {
      // 시스템 기본값일 경우 현재 locale 사용
      final locale = Localizations.localeOf(context);
      if (locale.countryCode == 'TW') {
        htmlLangCode = 'zh-TW';
      } else {
        htmlLangCode = locale.languageCode;
      }
    }

    final urlWithLang = '$url?lang=$htmlLangCode';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WebViewScreen(title: title, url: urlWithLang),
      ),
    );
  }

  String _getThemeLabel(AppLocalizations l10n) {
    switch (_themeMode) {
      case 'light':
        return l10n.themeLight;
      case 'dark':
        return l10n.themeDark;
      default:
        return l10n.themeSystem;
    }
  }

  void _showThemeDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.theme),
        content: RadioGroup<String>(
          groupValue: _themeMode,
          onChanged: (val) {
            if (val != null) {
              _setThemeMode(val);
              Navigator.pop(dialogContext);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(l10n.themeSystem, 'system'),
              _buildThemeOption(l10n.themeLight, 'light'),
              _buildThemeOption(l10n.themeDark, 'dark'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(String label, String value) {
    return ListTile(
      leading: Radio<String>(value: value),
      title: Text(label),
    );
  }

  void _showLanguageDialog(BuildContext context, AppLocalizations l10n) {
    final currentLocale = SpeakEnglishApp.localeNotifier.value;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.language),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: AppLanguage.supportedLanguages.length,
            itemBuilder: (context, index) {
              final lang = AppLanguage.supportedLanguages[index];
              final isSelected = currentLocale != null &&
                  currentLocale.languageCode == lang.locale.languageCode &&
                  (currentLocale.countryCode == lang.locale.countryCode ||
                      (currentLocale.countryCode == null &&
                          lang.locale.countryCode == null));

              return ListTile(
                leading: isSelected
                    ? Icon(
                        PhosphorIcons.check(PhosphorIconsStyle.bold),
                        color: Theme.of(context).primaryColor,
                      )
                    : const SizedBox(width: 24),
                title: Text(lang.nativeName),
                subtitle: Text(lang.name),
                onTap: () {
                  _setLanguage(lang);
                  Navigator.pop(dialogContext);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
