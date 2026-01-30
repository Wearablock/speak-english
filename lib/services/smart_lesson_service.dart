import '../models/lesson.dart';
import '../models/user_progress.dart';
import 'lesson_service.dart';
import 'progress_service.dart';
import 'preferences_service.dart';

/// 학습 통계 모델
class LearningStats {
  final int totalLessons;
  final int learnedCount;
  final int masteredCount;
  final int dueForReview;
  final Map<int, int> boxDistribution;

  const LearningStats({
    required this.totalLessons,
    required this.learnedCount,
    required this.masteredCount,
    required this.dueForReview,
    required this.boxDistribution,
  });

  double get learningProgress =>
      totalLessons > 0 ? learnedCount / totalLessons : 0.0;

  double get masterProgress =>
      totalLessons > 0 ? masteredCount / totalLessons : 0.0;
}

/// 레슨 타입 (UI 표시용)
enum LessonType { review, newLesson }

/// 스마트 레슨과 타입 정보
class SmartLesson {
  final Lesson lesson;
  final LessonType type;
  final UserProgress? progress;

  const SmartLesson({
    required this.lesson,
    required this.type,
    this.progress,
  });
}

class SmartLessonService {
  static final SmartLessonService _instance = SmartLessonService._internal();
  factory SmartLessonService() => _instance;
  SmartLessonService._internal();

  final LessonService _lessonService = LessonService();
  final ProgressService _progressService = ProgressService();

  /// 현재 언어 설정 가져오기
  String _getCurrentLocale() {
    return PreferencesService.getLanguage() ?? 'en';
  }

  /// 오늘의 학습 레슨 목록 생성
  Future<List<SmartLesson>> getDailyLessons() async {
    final dailyGoal = PreferencesService.getDailyGoal();
    final targetCount = dailyGoal.sentenceCount;

    final allLessons = await _lessonService.getLessons(locale: _getCurrentLocale());
    final allProgress = await _progressService.getAllProgress();
    final today = DateTime.now();

    // 1. 복습 필요 레슨 (60%)
    final reviewCount = (targetCount * 0.6).round();
    final reviewLessons = _getReviewLessons(
      allLessons,
      allProgress,
      today,
      reviewCount,
    );

    // 2. 새로운 레슨 (40%)
    final newCount = targetCount - reviewLessons.length;
    final newLessons = _getNewLessons(
      allLessons,
      allProgress,
      newCount,
    );

    // 3. 합치고 섞기
    final dailyLessons = [...reviewLessons, ...newLessons];
    dailyLessons.shuffle();

    return dailyLessons;
  }

  /// 단순 레슨 목록 반환 (기존 인터페이스 호환)
  Future<List<Lesson>> getDailyLessonsSimple() async {
    final smartLessons = await getDailyLessons();
    return smartLessons.map((sl) => sl.lesson).toList();
  }

  /// 복습 필요 레슨 선택
  List<SmartLesson> _getReviewLessons(
    List<Lesson> allLessons,
    Map<int, UserProgress> allProgress,
    DateTime today,
    int maxCount,
  ) {
    // 복습 예정일이 오늘이거나 지난 레슨 필터링
    final dueProgress = allProgress.values
        .where((p) => !p.isMastered) // 마스터한 건 제외
        .where((p) => _isDueForReview(p, today))
        .toList();

    // 우선순위 정렬: Box 낮은 순 → 정확도 낮은 순 → 오래된 순
    dueProgress.sort((a, b) {
      // 1. Box 낮은 순 (긴급한 복습 우선)
      final boxCompare = a.box.compareTo(b.box);
      if (boxCompare != 0) return boxCompare;

      // 2. 정확도 낮은 순
      final accCompare = a.bestAccuracy.compareTo(b.bestAccuracy);
      if (accCompare != 0) return accCompare;

      // 3. 오래된 순
      return a.lastPracticed.compareTo(b.lastPracticed);
    });

    // 레슨 ID로 실제 레슨 찾기
    final reviewLessons = <SmartLesson>[];
    for (final progress in dueProgress.take(maxCount)) {
      try {
        final lesson = allLessons.firstWhere(
          (l) => l.id == progress.lessonId,
        );
        reviewLessons.add(SmartLesson(
          lesson: lesson,
          type: LessonType.review,
          progress: progress,
        ));
      } catch (_) {
        // 레슨을 찾지 못한 경우 무시
      }
    }

    return reviewLessons;
  }

  /// 새로운 레슨 선택
  List<SmartLesson> _getNewLessons(
    List<Lesson> allLessons,
    Map<int, UserProgress> allProgress,
    int maxCount,
  ) {
    // 아직 학습하지 않은 레슨 필터링
    final newLessons = allLessons
        .where((l) => !allProgress.containsKey(l.id))
        .toList();

    // 난이도 → 카테고리 순 정렬
    newLessons.sort((a, b) {
      final diffCompare = a.difficulty.compareTo(b.difficulty);
      if (diffCompare != 0) return diffCompare;
      return a.categoryId.compareTo(b.categoryId);
    });

    return newLessons
        .take(maxCount)
        .map((l) => SmartLesson(
              lesson: l,
              type: LessonType.newLesson,
              progress: null,
            ))
        .toList();
  }

  /// 복습 예정일 체크
  bool _isDueForReview(UserProgress progress, DateTime today) {
    final reviewDate = DateTime(
      progress.nextReviewDate.year,
      progress.nextReviewDate.month,
      progress.nextReviewDate.day,
    );
    final todayDate = DateTime(today.year, today.month, today.day);
    return reviewDate.compareTo(todayDate) <= 0;
  }

  /// 학습 통계
  Future<LearningStats> getStats() async {
    final allProgress = await _progressService.getAllProgress();
    final allLessons = await _lessonService.getLessons(locale: _getCurrentLocale());

    final totalLessons = allLessons.length;
    final learnedCount = allProgress.length;
    final masteredCount = allProgress.values.where((p) => p.isMastered).length;
    final dueForReview = allProgress.values
        .where((p) => _isDueForReview(p, DateTime.now()))
        .length;

    // Box별 분포
    final boxDistribution = <int, int>{};
    for (final p in allProgress.values) {
      boxDistribution[p.box] = (boxDistribution[p.box] ?? 0) + 1;
    }

    return LearningStats(
      totalLessons: totalLessons,
      learnedCount: learnedCount,
      masteredCount: masteredCount,
      dueForReview: dueForReview,
      boxDistribution: boxDistribution,
    );
  }

  /// 오늘 복습 예정인 레슨 수
  Future<int> getDueForReviewCount() async {
    final allProgress = await _progressService.getAllProgress();
    final today = DateTime.now();
    return allProgress.values
        .where((p) => !p.isMastered && _isDueForReview(p, today))
        .length;
  }

  /// 새로 학습할 레슨 수
  Future<int> getNewLessonCount() async {
    final allLessons = await _lessonService.getLessons(locale: _getCurrentLocale());
    final allProgress = await _progressService.getAllProgress();
    return allLessons.where((l) => !allProgress.containsKey(l.id)).length;
  }
}
