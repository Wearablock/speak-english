import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/lesson.dart';
import '../models/lesson_category.dart';
import '../constants/app_config.dart';

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
  Future<bool> syncFromRemote() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localVersion = prefs.getString(_versionKey) ?? '0.0.0';

      // 버전 체크
      final versionResponse = await http.get(
        Uri.parse('${AppConfig.githubDataBaseUrl}/version.json'),
      ).timeout(const Duration(seconds: 10));

      if (versionResponse.statusCode != 200) return false;

      final versionData = jsonDecode(versionResponse.body);
      final remoteVersion = versionData['version'] as String;

      if (remoteVersion == localVersion) return true; // 이미 최신

      // 새 데이터 다운로드
      final dataResponse = await http.get(
        Uri.parse('${AppConfig.githubDataBaseUrl}/lessons.json'),
      ).timeout(const Duration(seconds: 30));

      if (dataResponse.statusCode != 200) return false;

      await prefs.setString(_lessonsKey, dataResponse.body);
      await prefs.setString(_versionKey, remoteVersion);

      // 캐시 무효화
      _cachedLessons = null;
      _cachedCategories = null;

      return true;
    } catch (e) {
      debugPrint('Sync failed: $e');
      return false;
    }
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
