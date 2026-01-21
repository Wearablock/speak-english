class UserProgress {
  final int lessonId;
  final double bestAccuracy;
  final int attemptCount;
  final DateTime lastPracticed;
  final bool isCompleted; // 80% 이상 달성

  const UserProgress({
    required this.lessonId,
    required this.bestAccuracy,
    required this.attemptCount,
    required this.lastPracticed,
    required this.isCompleted,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) => UserProgress(
    lessonId: json['lesson_id'] as int,
    bestAccuracy: (json['best_accuracy'] as num).toDouble(),
    attemptCount: json['attempt_count'] as int,
    lastPracticed: DateTime.parse(json['last_practiced'] as String),
    isCompleted: json['is_completed'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'lesson_id': lessonId,
    'best_accuracy': bestAccuracy,
    'attempt_count': attemptCount,
    'last_practiced': lastPracticed.toIso8601String(),
    'is_completed': isCompleted,
  };

  UserProgress copyWith({
    double? bestAccuracy,
    int? attemptCount,
    DateTime? lastPracticed,
    bool? isCompleted,
  }) => UserProgress(
    lessonId: lessonId,
    bestAccuracy: bestAccuracy ?? this.bestAccuracy,
    attemptCount: attemptCount ?? this.attemptCount,
    lastPracticed: lastPracticed ?? this.lastPracticed,
    isCompleted: isCompleted ?? this.isCompleted,
  );
}
