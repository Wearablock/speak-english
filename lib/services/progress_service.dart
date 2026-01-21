import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';
import '../constants/app_config.dart';

class ProgressService {
  // 싱글톤 패턴
  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;
  ProgressService._internal();

  static const String _progressKey = 'user_progress';
  static const String _streakKey = 'daily_streak';
  static const String _lastPracticeDateKey = 'last_practice_date';
  static const String _totalPracticeCountKey = 'total_practice_count';

  Map<int, UserProgress>? _cachedProgress;

  /// 모든 진도 조회
  Future<Map<int, UserProgress>> getAllProgress() async {
    if (_cachedProgress != null) return _cachedProgress!;

    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_progressKey);

    if (data == null) {
      _cachedProgress = {};
      return _cachedProgress!;
    }

    final jsonList = jsonDecode(data) as List;
    _cachedProgress = {
      for (final item in jsonList)
        item['lesson_id'] as int: UserProgress.fromJson(item as Map<String, dynamic>)
    };

    return _cachedProgress!;
  }

  /// 특정 레슨 진도 조회
  Future<UserProgress?> getProgress(int lessonId) async {
    final all = await getAllProgress();
    return all[lessonId];
  }

  /// 연습 결과 저장
  Future<void> saveResult(int lessonId, double accuracy) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAllProgress();

    final existing = all[lessonId];
    final now = DateTime.now();

    final updated = UserProgress(
      lessonId: lessonId,
      bestAccuracy: existing != null
          ? (accuracy > existing.bestAccuracy ? accuracy : existing.bestAccuracy)
          : accuracy,
      attemptCount: (existing?.attemptCount ?? 0) + 1,
      lastPracticed: now,
      isCompleted: accuracy >= AppConfig.completionThreshold ||
          (existing?.isCompleted ?? false),
    );

    all[lessonId] = updated;
    _cachedProgress = all;

    await prefs.setString(
      _progressKey,
      jsonEncode(all.values.map((e) => e.toJson()).toList()),
    );

    // 총 연습 횟수 업데이트
    final totalCount = prefs.getInt(_totalPracticeCountKey) ?? 0;
    await prefs.setInt(_totalPracticeCountKey, totalCount + 1);

    // 스트릭 업데이트
    await _updateStreak();

    // 다른 화면에 알림
    ProgressNotifier().notifyProgressUpdated();
  }

  /// 연속 학습일 조회
  Future<int> getDailyStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await _checkStreakReset();
    return prefs.getInt(_streakKey) ?? 0;
  }

  /// 완료한 레슨 수
  Future<int> getCompletedCount() async {
    final all = await getAllProgress();
    return all.values.where((p) => p.isCompleted).length;
  }

  /// 총 연습 횟수
  Future<int> getTotalPracticeCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalPracticeCountKey) ?? 0;
  }

  /// 오늘 연습한 레슨 수
  Future<int> getTodayPracticeCount() async {
    final all = await getAllProgress();
    final today = DateTime.now();

    return all.values.where((p) {
      return p.lastPracticed.year == today.year &&
          p.lastPracticed.month == today.month &&
          p.lastPracticed.day == today.day;
    }).length;
  }

  /// 평균 정확도
  Future<double> getAverageAccuracy() async {
    final all = await getAllProgress();
    if (all.isEmpty) return 0.0;

    final sum = all.values.fold<double>(0, (sum, p) => sum + p.bestAccuracy);
    return sum / all.length;
  }

  /// 스트릭 업데이트
  Future<void> _updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDateStr = prefs.getString(_lastPracticeDateKey);
    final today = DateTime.now();
    final todayStr = _formatDate(today);

    if (lastDateStr == todayStr) return; // 오늘 이미 업데이트됨

    int streak = prefs.getInt(_streakKey) ?? 0;

    if (lastDateStr != null) {
      final lastDate = _parseDate(lastDateStr);
      final difference = today.difference(lastDate).inDays;

      if (difference == 1) {
        streak++; // 연속
      } else if (difference > 1) {
        streak = 1; // 끊김, 리셋
      }
    } else {
      streak = 1; // 첫 연습
    }

    await prefs.setInt(_streakKey, streak);
    await prefs.setString(_lastPracticeDateKey, todayStr);
  }

  /// 스트릭 리셋 체크 (앱 시작 시)
  Future<void> _checkStreakReset() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDateStr = prefs.getString(_lastPracticeDateKey);

    if (lastDateStr == null) return;

    final lastDate = _parseDate(lastDateStr);
    final today = DateTime.now();
    final difference = today.difference(lastDate).inDays;

    if (difference > 1) {
      await prefs.setInt(_streakKey, 0);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}

/// 진도 변경 알림용 Notifier
class ProgressNotifier extends ChangeNotifier {
  static final ProgressNotifier _instance = ProgressNotifier._internal();
  factory ProgressNotifier() => _instance;
  ProgressNotifier._internal();

  void notifyProgressUpdated() => notifyListeners();
}
