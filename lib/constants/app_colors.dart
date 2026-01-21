import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF4A90D9);
  static const Color primaryLight = Color(0xFF7AB8F5);
  static const Color primaryDark = Color(0xFF2E6BB0);

  // Accent (성공/정확도 높음)
  static const Color accent = Color(0xFF50C878);
  static const Color accentLight = Color(0xFF7DDCA0);
  static const Color accentDark = Color(0xFF3DA85E);

  // 피드백 색상
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);

  // 정확도 색상
  static Color getAccuracyColor(double accuracy) {
    if (accuracy >= 0.8) return success;
    if (accuracy >= 0.6) return warning;
    return error;
  }

  // 중립 - 라이트 모드
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color disabled = Color(0xFFBDBDBD);

  // 다크 모드
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color surfaceDark = Color(0xFF2D2D44);
  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color dividerDark = Color(0xFF3D3D5C);
}
