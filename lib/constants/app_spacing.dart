import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  // 기본 간격
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // 테두리 반경
  static const double borderRadius = 12.0;
  static const double borderRadiusSm = 8.0;
  static const double borderRadiusLg = 16.0;
  static const double borderRadiusXl = 24.0;
  static const double borderRadiusFull = 999.0;

  // 아이콘 크기
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // 버튼 높이
  static const double buttonHeight = 48.0;
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightLg = 56.0;

  // 카드 패딩
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets cardPaddingSm = EdgeInsets.all(sm);
  static const EdgeInsets cardPaddingLg = EdgeInsets.all(lg);

  // 화면 패딩
  static const EdgeInsets screenPadding = EdgeInsets.all(md);
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(horizontal: md);

  // 리스트 간격
  static const double listSpacing = sm;
  static const double listSpacingLg = md;
}
