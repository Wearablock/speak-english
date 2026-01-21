import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class TextSimilarity {
  TextSimilarity._();

  /// 두 문장의 유사도 계산 (0.0 ~ 1.0)
  static double calculate(String spoken, String target) {
    final spokenNormalized = _normalize(spoken);
    final targetNormalized = _normalize(target);

    if (spokenNormalized == targetNormalized) return 1.0;
    if (spokenNormalized.isEmpty) return 0.0;
    if (targetNormalized.isEmpty) return 0.0;

    // 단어 단위 매칭
    final spokenWords = spokenNormalized.split(' ').toSet();
    final targetWords = targetNormalized.split(' ').toSet();

    final matches = spokenWords.intersection(targetWords).length;
    final wordAccuracy = matches / targetWords.length;

    // Levenshtein 거리 기반 보정
    final levenshteinScore = 1.0 - (_levenshteinDistance(
      spokenNormalized,
      targetNormalized,
    ) / max(targetNormalized.length, 1) * 1.5);

    // 두 점수의 가중 평균 (단어 매칭 70%, 문자 매칭 30%)
    final result = (wordAccuracy * 0.7 + levenshteinScore.clamp(0.0, 1.0) * 0.3);
    return result.clamp(0.0, 1.0);
  }

  /// 정확도에 따른 피드백 키 (l10n용)
  static String getFeedbackKey(double accuracy) {
    if (accuracy >= 0.95) return 'feedback_perfect';
    if (accuracy >= 0.8) return 'feedback_great';
    if (accuracy >= 0.6) return 'feedback_good';
    if (accuracy >= 0.4) return 'feedback_keep_practicing';
    return 'feedback_try_again';
  }

  /// 정확도에 따른 색상
  static Color getColor(double accuracy) {
    if (accuracy >= 0.8) return AppColors.success;
    if (accuracy >= 0.6) return AppColors.warning;
    return AppColors.error;
  }

  /// 퍼센트 문자열
  static String toPercentString(double accuracy) {
    return '${(accuracy * 100).round()}%';
  }

  /// 문자열 정규화
  static String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // 구두점 제거
        .replaceAll(RegExp(r'\s+'), ' ')    // 연속 공백 제거
        .trim();
  }

  /// Levenshtein 거리 계산
  static int _levenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> v0 = List<int>.generate(s2.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < s2.length; j++) {
        int cost = (s1[i] == s2[j]) ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost]
            .reduce((a, b) => a < b ? a : b);
      }
      List<int> temp = v0;
      v0 = v1;
      v1 = temp;
    }

    return v0[s2.length];
  }
}
