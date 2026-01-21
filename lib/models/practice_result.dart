class PracticeResult {
  final int lessonId;
  final String targetSentence;
  final String spokenText;
  final double accuracy;
  final DateTime timestamp;

  const PracticeResult({
    required this.lessonId,
    required this.targetSentence,
    required this.spokenText,
    required this.accuracy,
    required this.timestamp,
  });

  /// 정확도에 따른 피드백 키 (l10n용)
  String get feedbackKey {
    if (accuracy >= 0.95) return 'feedback_perfect';
    if (accuracy >= 0.8) return 'feedback_great';
    if (accuracy >= 0.6) return 'feedback_good';
    if (accuracy >= 0.4) return 'feedback_keep_practicing';
    return 'feedback_try_again';
  }

  /// 80% 이상이면 통과
  bool get isPassed => accuracy >= 0.8;
}
