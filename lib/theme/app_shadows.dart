import 'package:flutter/material.dart';

/// 앱에서 사용하는 그림자 스타일들을 정의합니다.
class AppShadows {
  // 기본 카드 그림자
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x1A000000), // 10% 투명도
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  // 버튼 그림자
  static const List<BoxShadow> button = [
    BoxShadow(
      color: Color(0x1A000000), // 10% 투명도
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  // 큰 그림자 (모달, 다이얼로그 등)
  static const List<BoxShadow> large = [
    BoxShadow(
      color: Color(0x33000000), // 20% 투명도
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  // 작은 그림자 (입력 필드 등)
  static const List<BoxShadow> small = [
    BoxShadow(
      color: Color(0x0D000000), // 5% 투명도
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  // 그림자 없음
  static const List<BoxShadow> none = [];
}
