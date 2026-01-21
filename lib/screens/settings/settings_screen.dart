import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../l10n/app_localizations.dart';
import '../../constants/app_config.dart';
import '../../services/preferences_service.dart';
import '../../app.dart';

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

    // 앱 테마 변경
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

          // 언어 설정 (Phase 4에서 구현)
          ListTile(
            leading: Icon(PhosphorIcons.globe(PhosphorIconsStyle.regular)),
            title: Text(l10n.language),
            subtitle: const Text('English'),
            trailing: Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold)),
            onTap: () {
              // TODO: Phase 4에서 구현
            },
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
}
