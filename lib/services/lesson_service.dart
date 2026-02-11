import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/lesson.dart';
import '../models/lesson_category.dart';
import '../constants/app_config.dart';

/// 동기화 상태
enum SyncStatus {
  idle,
  checking,
  downloading,
  completed,
  failed,
  upToDate,
}

/// 동기화 결과
class SyncResult {
  final SyncStatus status;
  final String? newVersion;
  final String? errorMessage;
  final int? newLessonCount;

  SyncResult({
    required this.status,
    this.newVersion,
    this.errorMessage,
    this.newLessonCount,
  });

  bool get isSuccess => status == SyncStatus.completed || status == SyncStatus.upToDate;
}

class LessonService {
  // 싱글톤 패턴
  static final LessonService _instance = LessonService._internal();
  factory LessonService() => _instance;
  LessonService._internal();

  static const String _lessonsKey = 'lessons_data';
  static const String _translationsKeyPrefix = 'translations_';
  static const String _versionKey = 'lessons_version';

  List<Lesson>? _cachedLessons;
  List<LessonCategory>? _cachedCategories;
  String? _cachedLocale;

  /// 지원 언어 목록
  static const List<String> supportedLanguages = [
    'en', 'ko', 'ja', 'zh_CN', 'zh_TW',
    'es', 'fr', 'de', 'it', 'pt',
    'ru', 'ar', 'hi', 'th', 'vi'
  ];

  /// 로케일 코드를 파일명 형식으로 변환
  String _normalizeLocale(String locale) {
    // zh-TW, zh_TW, zh-Hant -> zh_TW
    if (locale.startsWith('zh') &&
        (locale.contains('TW') || locale.contains('Hant'))) {
      return 'zh_TW';
    }
    // zh, zh-CN, zh_CN, zh-Hans -> zh_CN
    if (locale.startsWith('zh')) {
      return 'zh_CN';
    }
    // en-US, en_US -> en
    final baseLanguage = locale.split(RegExp(r'[-_]')).first;

    // 지원 언어 확인
    if (supportedLanguages.contains(baseLanguage)) {
      return baseLanguage;
    }

    return 'en'; // 기본값
  }

  /// 모든 레슨 조회 (현재 로케일 번역 포함)
  Future<List<Lesson>> getLessons({String? locale}) async {
    final targetLocale = _normalizeLocale(locale ?? 'en');

    // 캐시 확인 (같은 로케일인 경우)
    if (_cachedLessons != null && _cachedLocale == targetLocale) {
      return _cachedLessons!;
    }

    final prefs = await SharedPreferences.getInstance();

    // 1. 레슨 기본 데이터 로드
    // - 우선: SharedPreferences (GitHub 원격에서 동기화된 전체 데이터)
    // - fallback: assets/data/lessons.json (최소 데이터, 오프라인 첫 실행용)
    String? lessonsData = prefs.getString(_lessonsKey);
    if (lessonsData == null) {
      lessonsData = await rootBundle.loadString('assets/data/lessons.json');
    }

    // 2. 번역 데이터 로드
    String? translationsData = prefs.getString('$_translationsKeyPrefix$targetLocale');
    if (translationsData == null) {
      try {
        translationsData = await rootBundle.loadString(
          'assets/data/translations/$targetLocale.json'
        );
      } catch (e) {
        // 번역 파일 없으면 영어 사용
        translationsData = await rootBundle.loadString(
          'assets/data/translations/en.json'
        );
      }
    }

    // 3. 데이터 파싱 및 병합
    _parseAndMergeData(lessonsData, translationsData, targetLocale);
    _cachedLocale = targetLocale;

    return _cachedLessons!;
  }

  /// 모든 카테고리 조회
  Future<List<LessonCategory>> getCategories() async {
    if (_cachedCategories != null) return _cachedCategories!;
    await getLessons();
    return _cachedCategories!;
  }

  /// 카테고리별 레슨 조회
  Future<List<Lesson>> getLessonsByCategory(int categoryId, {String? locale}) async {
    final lessons = await getLessons(locale: locale);
    return lessons.where((l) => l.categoryId == categoryId).toList();
  }

  /// 난이도별 레슨 조회
  Future<List<Lesson>> getLessonsByDifficulty(int difficulty, {String? locale}) async {
    final lessons = await getLessons(locale: locale);
    return lessons.where((l) => l.difficulty == difficulty).toList();
  }

  /// ID로 레슨 조회
  Future<Lesson?> getLessonById(int id, {String? locale}) async {
    final lessons = await getLessons(locale: locale);
    try {
      return lessons.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  /// GitHub에서 새 데이터 동기화
  Future<SyncResult> syncFromRemote({String? locale}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localVersion = prefs.getString(_versionKey) ?? '0.0.0';
      final targetLocale = _normalizeLocale(locale ?? 'en');

      // 1. 버전 체크
      final versionResponse = await http.get(
        Uri.parse('${AppConfig.githubDataBaseUrl}/version.json'),
      ).timeout(const Duration(seconds: 10));

      if (versionResponse.statusCode != 200) {
        return SyncResult(
          status: SyncStatus.failed,
          errorMessage: 'Version check failed: ${versionResponse.statusCode}',
        );
      }

      final versionData = jsonDecode(versionResponse.body);
      final remoteVersion = versionData['version'] as String;
      final minAppVersion = versionData['minAppVersion'] as String?;

      // 2. 앱 버전 호환성 체크
      if (minAppVersion != null && !_isAppVersionCompatible(minAppVersion)) {
        return SyncResult(
          status: SyncStatus.failed,
          errorMessage: 'App update required. Minimum version: $minAppVersion',
        );
      }

      // 3. 이미 최신인지 확인
      if (_compareVersions(remoteVersion, localVersion) <= 0) {
        return SyncResult(status: SyncStatus.upToDate);
      }

      // 4. 레슨 기본 데이터 다운로드
      final lessonsResponse = await http.get(
        Uri.parse('${AppConfig.githubDataBaseUrl}/lessons.json'),
      ).timeout(const Duration(seconds: 30));

      if (lessonsResponse.statusCode != 200) {
        return SyncResult(
          status: SyncStatus.failed,
          errorMessage: 'Lessons download failed: ${lessonsResponse.statusCode}',
        );
      }

      // 5. 번역 데이터 다운로드 (현재 언어)
      final translationsResponse = await http.get(
        Uri.parse('${AppConfig.githubDataBaseUrl}/translations/$targetLocale.json'),
      ).timeout(const Duration(seconds: 30));

      if (translationsResponse.statusCode != 200) {
        return SyncResult(
          status: SyncStatus.failed,
          errorMessage: 'Translations download failed: ${translationsResponse.statusCode}',
        );
      }

      // 6. 데이터 유효성 검사
      int lessonCount = 0;
      try {
        final testData = jsonDecode(lessonsResponse.body);
        if (testData['lessons'] == null || testData['categories'] == null) {
          throw const FormatException('Invalid data format');
        }
        lessonCount = (testData['lessons'] as List).length;

        // 번역 데이터 검증
        jsonDecode(translationsResponse.body);
      } catch (e) {
        return SyncResult(
          status: SyncStatus.failed,
          errorMessage: 'Invalid data format',
        );
      }

      // 7. 로컬 저장
      await prefs.setString(_lessonsKey, lessonsResponse.body);
      await prefs.setString('$_translationsKeyPrefix$targetLocale', translationsResponse.body);
      await prefs.setString(_versionKey, remoteVersion);

      // 8. 캐시 무효화
      _cachedLessons = null;
      _cachedCategories = null;
      _cachedLocale = null;

      debugPrint('Data synced: v$localVersion -> v$remoteVersion ($lessonCount lessons)');

      return SyncResult(
        status: SyncStatus.completed,
        newVersion: remoteVersion,
        newLessonCount: lessonCount,
      );
    } on TimeoutException {
      return SyncResult(
        status: SyncStatus.failed,
        errorMessage: 'Connection timeout',
      );
    } on SocketException {
      return SyncResult(
        status: SyncStatus.failed,
        errorMessage: 'No internet connection',
      );
    } catch (e) {
      debugPrint('Sync failed: $e');
      return SyncResult(
        status: SyncStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  /// 특정 언어 번역만 다운로드
  Future<bool> downloadTranslation(String locale) async {
    try {
      final targetLocale = _normalizeLocale(locale);
      final prefs = await SharedPreferences.getInstance();

      final response = await http.get(
        Uri.parse('${AppConfig.githubDataBaseUrl}/translations/$targetLocale.json'),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        return false;
      }

      await prefs.setString('$_translationsKeyPrefix$targetLocale', response.body);

      // 현재 캐시된 로케일이면 무효화
      if (_cachedLocale == targetLocale) {
        _cachedLessons = null;
        _cachedLocale = null;
      }

      return true;
    } catch (e) {
      debugPrint('Translation download failed: $e');
      return false;
    }
  }

  /// 버전 비교 (semver)
  int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final parts2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < 3; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;
      if (p1 != p2) return p1.compareTo(p2);
    }
    return 0;
  }

  /// 앱 버전 호환성 체크
  bool _isAppVersionCompatible(String minVersion) {
    return _compareVersions(AppConfig.appVersion, minVersion) >= 0;
  }

  /// 현재 데이터 버전 조회
  Future<String> getCurrentVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_versionKey) ?? '0.0.0';
  }

  /// JSON 파싱 및 번역 병합
  void _parseAndMergeData(String lessonsJson, String translationsJson, String locale) {
    final lessonsData = jsonDecode(lessonsJson);
    final translationsData = jsonDecode(translationsJson) as Map<String, dynamic>;

    // 카테고리 파싱
    _cachedCategories = (lessonsData['categories'] as List)
        .map((e) => LessonCategory.fromJson(e as Map<String, dynamic>))
        .toList();

    // 레슨 파싱 및 번역 병합
    _cachedLessons = (lessonsData['lessons'] as List).map((e) {
      final lessonMap = e as Map<String, dynamic>;
      final lessonId = lessonMap['id'].toString();

      // 번역 데이터 병합
      final translations = <String, String>{
        'en': lessonMap['sentence'] as String,
      };

      if (translationsData.containsKey(lessonId)) {
        translations[locale] = translationsData[lessonId] as String;
      }

      return Lesson(
        id: lessonMap['id'] as int,
        sentence: lessonMap['sentence'] as String,
        translations: translations,
        categoryId: lessonMap['category_id'] as int,
        difficulty: lessonMap['difficulty'] as int? ?? 1,
      );
    }).toList();

    // 카테고리별 레슨 수 업데이트
    for (final category in _cachedCategories!) {
      category.lessonCount = _cachedLessons!
          .where((l) => l.categoryId == category.id)
          .length;
    }
  }

  /// 캐시 초기화 (로케일 변경 시)
  void clearCache() {
    _cachedLessons = null;
    _cachedCategories = null;
    _cachedLocale = null;
  }
}
