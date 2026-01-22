import 'dart:math';

class UserProgress {
  final int lessonId;
  final double bestAccuracy;
  final double lastAccuracy;
  final int attemptCount;
  final DateTime lastPracticed;
  final DateTime nextReviewDate;
  final bool isCompleted;
  final int box; // Leitner Box (1~5)
  final int consecutiveSuccess;
  final bool isMastered;

  /// Box별 복습 간격 (일)
  static const List<int> boxIntervals = [1, 2, 4, 7, 14];

  const UserProgress({
    required this.lessonId,
    required this.bestAccuracy,
    this.lastAccuracy = 0.0,
    required this.attemptCount,
    required this.lastPracticed,
    DateTime? nextReviewDate,
    required this.isCompleted,
    this.box = 1,
    this.consecutiveSuccess = 0,
    this.isMastered = false,
  }) : nextReviewDate = nextReviewDate ?? lastPracticed;

  /// Box에 따른 다음 복습일 계산
  static DateTime calculateNextReview(int box, DateTime from) {
    final days = box > 0 && box <= 5 ? boxIntervals[box - 1] : 1;
    return DateTime(from.year, from.month, from.day + days);
  }

  /// 학습 결과 반영
  UserProgress updateWithResult(double accuracy) {
    final passed = accuracy >= 0.8;
    final newBox = passed ? min(box + 1, 5) : 1;
    final newConsecutive = passed ? consecutiveSuccess + 1 : 0;
    final now = DateTime.now();

    return UserProgress(
      lessonId: lessonId,
      bestAccuracy: max(accuracy, bestAccuracy),
      lastAccuracy: accuracy,
      attemptCount: attemptCount + 1,
      lastPracticed: now,
      nextReviewDate: calculateNextReview(newBox, now),
      isCompleted: passed || isCompleted,
      box: newBox,
      consecutiveSuccess: newConsecutive,
      isMastered: newBox >= 5,
    );
  }

  /// 첫 학습 결과로 진도 생성
  factory UserProgress.fromFirstAttempt(int lessonId, double accuracy) {
    final passed = accuracy >= 0.8;
    final now = DateTime.now();
    final initialBox = passed ? 2 : 1;

    return UserProgress(
      lessonId: lessonId,
      bestAccuracy: accuracy,
      lastAccuracy: accuracy,
      attemptCount: 1,
      lastPracticed: now,
      nextReviewDate: calculateNextReview(initialBox, now),
      isCompleted: passed,
      box: initialBox,
      consecutiveSuccess: passed ? 1 : 0,
      isMastered: false,
    );
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) => UserProgress(
        lessonId: json['lesson_id'] as int,
        bestAccuracy: (json['best_accuracy'] as num).toDouble(),
        lastAccuracy: (json['last_accuracy'] as num?)?.toDouble() ?? 0.0,
        attemptCount: json['attempt_count'] as int,
        lastPracticed: DateTime.parse(json['last_practiced'] as String),
        nextReviewDate: json['next_review_date'] != null
            ? DateTime.parse(json['next_review_date'] as String)
            : null,
        isCompleted: json['is_completed'] as bool,
        box: json['box'] as int? ?? 1,
        consecutiveSuccess: json['consecutive_success'] as int? ?? 0,
        isMastered: json['is_mastered'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'lesson_id': lessonId,
        'best_accuracy': bestAccuracy,
        'last_accuracy': lastAccuracy,
        'attempt_count': attemptCount,
        'last_practiced': lastPracticed.toIso8601String(),
        'next_review_date': nextReviewDate.toIso8601String(),
        'is_completed': isCompleted,
        'box': box,
        'consecutive_success': consecutiveSuccess,
        'is_mastered': isMastered,
      };

  UserProgress copyWith({
    double? bestAccuracy,
    double? lastAccuracy,
    int? attemptCount,
    DateTime? lastPracticed,
    DateTime? nextReviewDate,
    bool? isCompleted,
    int? box,
    int? consecutiveSuccess,
    bool? isMastered,
  }) =>
      UserProgress(
        lessonId: lessonId,
        bestAccuracy: bestAccuracy ?? this.bestAccuracy,
        lastAccuracy: lastAccuracy ?? this.lastAccuracy,
        attemptCount: attemptCount ?? this.attemptCount,
        lastPracticed: lastPracticed ?? this.lastPracticed,
        nextReviewDate: nextReviewDate ?? this.nextReviewDate,
        isCompleted: isCompleted ?? this.isCompleted,
        box: box ?? this.box,
        consecutiveSuccess: consecutiveSuccess ?? this.consecutiveSuccess,
        isMastered: isMastered ?? this.isMastered,
      );
}
