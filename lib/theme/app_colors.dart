import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Colors (주 색상)
  static const Color primary = Color(0xFFF97316); // Orange-500 - 활성 버튼, 앱바, 포커스 상태
  static const Color primaryLight = Color(0xFFFDBA74); // Orange-300 - 모달 세부 정보
  static const Color primaryDisabled = Color(0xFFFED7AA); // Orange-200 - 비활성 버튼, 검색 필드 테두리
  
  // Background Colors (배경 색상)
  static const Color background = Color(0xFFFFF5DF); // Ivory-100 - 화면
  static const Color surface = Color(0xFFF5E6D3); // Ivory-200 - 모달, 카드
  static const Color appBarBackground = Color(0xFFE7D5B7); // Ivory-300 - 상단 앱바
  static const Color surfaceVariant = Color(0xFFFAFAFA); // Gray-50 - 입력 필드, 드롭다운
  
  // UI Element Colors (UI 요소 색상)
  static const Color dropdownIcon = Color(0xFFD1D5DB); // Gray-300 - 드롭다운 버튼
  
  // Text Colors (텍스트 색상)
  static const Color textPrimary = Color(0xFF374151); // Gray-700 - 제목, 본문 텍스트
  static const Color textSecondary = Color(0xFF6B7280); // Gray-600 - 모달 본문 텍스트
  static const Color textHint = Color(0xFFD1D5DB); // Gray-300 - 입력 필드 힌트 텍스트
  static const Color textSelected = Color(0xFF111827); // Gray-900 - 검색 적용된 지역명 텍스트
  
  // Colored Text Colors (컬러 텍스트 색상)
  static const Color textColored1 = Color(0xFFF97316); // Orange-500 - 입력 필드 라벨, 본문 텍스트
  static const Color textColored2 = Color(0xFFFB923C); // Orange-400 - 검색 전 텍스트
  static const Color textColored3 = Color(0xFFEA580C); // Orange-600-80 - 검색 후 + 운행 전 텍스트
  static const Color textColored4 = Color(0xFFF5E6D3); // Ivory-200 - 모달 제목 텍스트
  
  // Status Colors (상태 색상)
  static const Color error = Color(0xFFF44336); // Red-500 - 에러 필드 테두리, 에러 문구
  static const Color success = Color(0xFF4CAF50); // Green-500 - 성공 상태
  
  // Additional Colors (추가 색상)
  static const Color white = Color(0xFFFFFFFF); // White
  static const Color secondary = Color(0xFF6B7280); // Gray-500 - 보조 색상
  static const Color grey300 = Color(0xFFD1D5DB); // Gray-300
  static const Color grey800 = Color(0xFF1F2937); // Gray-800
  static const Color grey900 = Color(0xFF111827); // Gray-900
}