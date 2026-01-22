enum DailyGoalType {
  light, // 조금
  normal, // 보통
  intense, // 많이
  custom, // 커스텀
}

class DailyGoal {
  final DailyGoalType type;
  final int sentenceCount;

  const DailyGoal({
    required this.type,
    required this.sentenceCount,
  });

  /// 프리셋 학습량
  static const DailyGoal light = DailyGoal(
    type: DailyGoalType.light,
    sentenceCount: 5,
  );

  static const DailyGoal normal = DailyGoal(
    type: DailyGoalType.normal,
    sentenceCount: 10,
  );

  static const DailyGoal intense = DailyGoal(
    type: DailyGoalType.intense,
    sentenceCount: 20,
  );

  static DailyGoal custom(int count) => DailyGoal(
        type: DailyGoalType.custom,
        sentenceCount: count.clamp(1, 50),
      );

  /// 예상 소요 시간 (분)
  int get estimatedMinutes => (sentenceCount * 0.5).ceil();

  /// JSON 직렬화
  Map<String, dynamic> toJson() => {
        'type': type.name,
        'sentenceCount': sentenceCount,
      };

  factory DailyGoal.fromJson(Map<String, dynamic> json) {
    final type = DailyGoalType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => DailyGoalType.normal,
    );
    final count = json['sentenceCount'] as int? ?? 10;

    return switch (type) {
      DailyGoalType.light => DailyGoal.light,
      DailyGoalType.normal => DailyGoal.normal,
      DailyGoalType.intense => DailyGoal.intense,
      DailyGoalType.custom => DailyGoal.custom(count),
    };
  }
}
