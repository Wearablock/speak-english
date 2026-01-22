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
  static const String _versionKey = 'lessons_version';

  List<Lesson>? _cachedLessons;
  List<LessonCategory>? _cachedCategories;

  /// 모든 레슨 조회
  Future<List<Lesson>> getLessons() async {
    if (_cachedLessons != null) return _cachedLessons!;

    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_lessonsKey);

    if (data != null) {
      _parseData(data);
      return _cachedLessons!;
    }

    // 로컬 데이터 없으면 assets에서 로드
    return await _loadFromAssets();
  }

  /// 모든 카테고리 조회
  Future<List<LessonCategory>> getCategories() async {
    if (_cachedCategories != null) return _cachedCategories!;
    await getLessons(); // 레슨 로드 시 카테고리도 함께 파싱됨
    return _cachedCategories!;
  }

  /// 카테고리별 레슨 조회
  Future<List<Lesson>> getLessonsByCategory(int categoryId) async {
    final lessons = await getLessons();
    return lessons.where((l) => l.categoryId == categoryId).toList();
  }

  /// 난이도별 레슨 조회
  Future<List<Lesson>> getLessonsByDifficulty(int difficulty) async {
    final lessons = await getLessons();
    return lessons.where((l) => l.difficulty == difficulty).toList();
  }

  /// ID로 레슨 조회
  Future<Lesson?> getLessonById(int id) async {
    final lessons = await getLessons();
    try {
      return lessons.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  /// GitHub에서 새 데이터 동기화
  Future<SyncResult> syncFromRemote() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localVersion = prefs.getString(_versionKey) ?? '0.0.0';

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

      // 4. 새 데이터 다운로드
      final dataResponse = await http.get(
        Uri.parse('${AppConfig.githubDataBaseUrl}/lessons.json'),
      ).timeout(const Duration(seconds: 30));

      if (dataResponse.statusCode != 200) {
        return SyncResult(
          status: SyncStatus.failed,
          errorMessage: 'Data download failed: ${dataResponse.statusCode}',
        );
      }

      // 5. 데이터 유효성 검사
      int lessonCount = 0;
      try {
        final testData = jsonDecode(dataResponse.body);
        if (testData['lessons'] == null || testData['categories'] == null) {
          throw const FormatException('Invalid data format');
        }
        lessonCount = (testData['lessons'] as List).length;
      } catch (e) {
        return SyncResult(
          status: SyncStatus.failed,
          errorMessage: 'Invalid data format',
        );
      }

      // 6. 로컬 저장
      await prefs.setString(_lessonsKey, dataResponse.body);
      await prefs.setString(_versionKey, remoteVersion);

      // 7. 캐시 무효화
      _cachedLessons = null;
      _cachedCategories = null;

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

  /// Assets에서 초기 데이터 로드
  Future<List<Lesson>> _loadFromAssets() async {
    final jsonString = await rootBundle.loadString('assets/data/lessons_v1.json');
    _parseData(jsonString);
    return _cachedLessons!;
  }

  /// JSON 파싱
  void _parseData(String jsonString) {
    final data = jsonDecode(jsonString);

    _cachedLessons = (data['lessons'] as List)
        .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
        .toList();

    _cachedCategories = (data['categories'] as List)
        .map((e) => LessonCategory.fromJson(e as Map<String, dynamic>))
        .toList();

    // 카테고리별 레슨 수 업데이트
    for (final category in _cachedCategories!) {
      category.lessonCount = _cachedLessons!
          .where((l) => l.categoryId == category.id)
          .length;
    }
  }
}
