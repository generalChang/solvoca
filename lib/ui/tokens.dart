import 'package:flutter/material.dart';

/// Latte cream tokens. The one place screens and components read color, type,
/// and shape from.
abstract final class SolvocaTokens {
  static const fontFamily = 'Pretendard';

  static const background = Color(0xFFF5F0E8);
  static const surface = Color(0xFFFFFCF7);
  static const textPrimary = Color(0xFF3D3229);
  static const textSecondary = Color(0xFF7A6B5D);
  static const accent = Color(0xFFC4775A);
  static const onAccent = Color(0xFFFFFCF7);
  static const accentSoft = Color(0xFFE8D5C4);
  static const border = Color(0xFFE0D4C8);
  static const shadow = Color(0x1A3D3229);

  static const radiusStudyCard = 24.0;
  static const radiusButton = 14.0;
  static const radiusListRow = 16.0;
  static const radiusTabPill = 28.0;
  static const radiusTabSegment = 22.0;
  static const radiusSheet = 24.0;
  static const radiusDialog = 20.0;

  static const studyCardHeight = 240.0;
  static const buttonHeight = 52.0;

  static const secondaryBorder = BorderSide(
    color: Color(0x73C4775A),
    width: 1,
  );

  static const liftShadow = [
    BoxShadow(
      color: shadow,
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];
}
