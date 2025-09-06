import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 앱에서 사용하는 모든 텍스트 스타일을 정의하는 클래스
class AppTextStyles {
  // Private constructor to prevent instantiation
  AppTextStyles._();
  // ========================================
  // 앱 전용 텍스트 스타일 (App Specific Text Styles)
  // ========================================

  /// 네비게이터 탭 텍스트 스타일 (활성화)
  /// Text/Button/L-Bold
  /// fontSize: 16.sp
  /// lineHeight: 19.sp
  /// fontFamily: Pretendard
  /// fontWeight: 700
  /// color: GrayscaleGray50
  static const TextStyle navigatorTab = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.1875, // 19sp / 16sp = 118.75%
    letterSpacing: 0,
    color: Color(0xFFFEFEFE), // GrayscaleGray50
    fontFamily: 'Pretendard',
  );

  /// 네비게이터 탭 텍스트 스타일 (비활성화)
  /// Text/Button/L-Bold
  /// fontSize: 16.sp
  /// lineHeight: 19.sp
  /// fontFamily: Pretendard
  /// fontWeight: 700
  /// color: PrimaryOrange500
  static const TextStyle navigatorTabInactive = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.1875, // 19sp / 16sp = 118.75%
    letterSpacing: 0,
    color: Color(0xFFFFA550), // PrimaryOrange500
    fontFamily: 'Pretendard',
  );

  /// 커스텀 버튼 텍스트 스타일
  /// Text/Button/L-Bold
  /// fontSize: 16.sp
  /// lineHeight: 19.sp
  /// fontFamily: Pretendard
  /// fontWeight: 700
  /// color: GrayscaleGray50
  /// textAlign: Center
  static const TextStyle customButton = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.1875, // 19sp / 16sp = 118.75%
    letterSpacing: 0,
    color: Color(0xFFFEFEFE), // GrayscaleGray50
    fontFamily: 'Pretendard',
  );

  /// 카카오 버튼 텍스트 스타일
  /// Text/Button/L-Bold
  /// fontSize: 16.sp
  /// lineHeight: 19.sp
  /// fontFamily: Pretendard
  /// fontWeight: 700
  /// color: GrayscaleGray900
  /// textAlign: Center
  static const TextStyle kakaoButton = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.1875, // 19sp / 16sp = 118.75%
    letterSpacing: 0,
    color: Color(0xFF1A1A1A), // GrayscaleGray900
    fontFamily: 'Pretendard',
  );

  /// 입력 필드 힌트 텍스트 스타일
  /// Text/Body/S-Medium
  /// fontSize: 12.sp
  /// lineHeight: 14.sp
  /// fontFamily: Pretendard
  /// fontWeight: 500
  /// color: GrayscaleGray300
  static const TextStyle inputHint = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.16667, // 14sp / 12sp = 116.667%
    letterSpacing: 0,
    color: Color(0xFFD1D5DB), // GrayscaleGray300
    fontFamily: 'Pretendard',
  );

  /// 입력 필드 라벨 텍스트 스타일
  /// Text/Body/S-Bold
  /// fontSize: 12.sp
  /// lineHeight: 20.16.sp
  /// fontFamily: Pretendard
  /// fontWeight: 700
  /// color: PrimaryOrange500
  static const TextStyle inputLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.68, // 20.16sp / 12sp = 168%
    letterSpacing: 0,
    color: Color(0xFFFFA550), // PrimaryOrange500
    fontFamily: 'Pretendard',
  );

  /// 회원가입, 구분선 텍스트 스타일
  /// Text/Body/S-Medium
  /// fontSize: 12.sp
  /// lineHeight: 14.sp
  /// fontFamily: Pretendard
  /// fontWeight: 500
  /// color: PrimaryOrange400
  /// textAlign: Right
  static const TextStyle signupTextButton = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.16667, // 14sp / 12sp = 116.667%
    letterSpacing: 0,
    color: Color(0xFFFFB06F), // PrimaryOrange400
    fontFamily: 'Pretendard',
  );

  /// 입력 필드 에러 문구 스타일
  /// Text/Body/S-Medium
  /// fontSize: 12.sp
  /// lineHeight: 14.sp
  /// fontFamily: Pretendard
  /// fontWeight: 500
  /// color: ErrorDanger
  static const TextStyle inputError = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.16667, // 14sp / 12sp = 116.667%
    letterSpacing: 0,
    color: Color(0xFFFF4D4D), // ErrorDanger
    fontFamily: 'Pretendard',
  );

  /// 입력 필드 텍스트 스타일
  /// Text/Body/S-Medium
  /// fontSize: 12.sp
  /// lineHeight: 14.sp
  /// fontFamily: Pretendard
  /// fontWeight: 500
  /// color: GrayscaleGray700
  static const TextStyle inputText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.16667, // 14sp / 12sp = 116.667%
    letterSpacing: 0,
    color: Color(0xFF616161), // GrayscaleGray700
    fontFamily: 'Pretendard',
  );

  /// 드롭다운 선택된 항목 텍스트 스타일
  /// Text/Body/S-Medium
  /// fontSize: 12.sp
  /// lineHeight: 14.sp
  /// fontFamily: Pretendard
  /// fontWeight: 500
  /// color: PrimaryOrange600
  static const TextStyle dropdownSelected = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.1667, // 14sp / 12sp = 116.67%
    letterSpacing: 0,
    color: Color(0xFFEA580C), // PrimaryOrange600
    fontFamily: 'Pretendard',
  );

  /// 드롭다운 비선택 항목 텍스트 스타일
  /// Text/Body/S-Medium
  /// fontSize: 12.sp
  /// lineHeight: 14.sp
  /// fontFamily: Pretendard
  /// fontWeight: 500
  /// color: GrayscaleGray700
  static const TextStyle dropdownUnselected = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.1667, // 14sp / 12sp = 116.67%
    letterSpacing: 0,
    color: Color(0xFF374151), // GrayscaleGray700
    fontFamily: 'Pretendard',
  );

  /// 로그인 문구 텍스트 스타일
  /// Text/Body/S-Bold
  /// fontSize: 12.sp
  /// lineHeight: 20.16.sp
  /// fontFamily: Pretendard
  /// fontWeight: 700
  /// color: PrimaryOrange500
  /// textAlign: Center
  static const TextStyle loginText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.68, // 20.16sp / 12sp = 168%
    letterSpacing: 0,
    color: Color(0xFFFFA550), // PrimaryOrange500
    fontFamily: 'Pretendard',
  );

  /// 스플래시 안내 문구 텍스트 스타일
  /// Text/Body/S-Bold
  /// fontSize: 12.sp
  /// lineHeight: 20.16.sp
  /// fontFamily: Pretendard
  /// fontWeight: 700
  /// color: NeutralIvory100
  /// textAlign: Center
  static const TextStyle splashGuide = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.68, // 20.16sp / 12sp = 168%
    letterSpacing: 0,
    color: Color(0xFFFFF5DF), // NeutralIvory100
    fontFamily: 'Pretendard',
  );

  /// 서치 스크린 본문 텍스트 스타일
  /// Text/Body/L-Semibold
  /// fontSize: 16.sp
  /// lineHeight: 24.sp
  /// fontFamily: Pretendard
  /// fontWeight: 600
  /// color: PrimaryOrange400
  static const TextStyle searchScreenBody = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5, // 24px / 16px = 150%
    letterSpacing: 0,
    color: Color(0xFFFFB06F), // PrimaryOrange400
    fontFamily: 'Pretendard',
  );

  /// 신청현황 운행전 본문 텍스트 스타일
  /// Text/Body/L-Semibold
  /// fontSize: 16.sp
  /// lineHeight: 24.sp
  /// fontFamily: Pretendard
  /// fontWeight: 600
  /// color: PrimaryOrange60080
  /// textAlign: Center
  static const TextStyle applicationStatusBody = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5, // 24sp / 16sp = 150%
    letterSpacing: 0,
    color: Color(0xCCFF9A3D), // PrimaryOrange60080 (80% opacity)
    fontFamily: 'Pretendard',
  );

  /// 신청현황 운행시작 텍스트 스타일
  /// Text/Body/L-Semibold
  /// fontSize: 16.sp
  /// lineHeight: 24.sp
  /// fontFamily: Pretendard
  /// fontWeight: 600
  /// color: PrimaryOrange500
  /// textAlign: Center
  static const TextStyle applicationStatusStarted = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5, // 24sp / 16sp = 150%
    letterSpacing: 0,
    color: Color(0xFFFFA550), // PrimaryOrange500
    fontFamily: 'Pretendard',
  );

  /// 신청 완료 모달 텍스트 스타일
  /// Text/Button/L-Bold
  /// fontSize: 16.sp
  /// lineHeight: 19.sp
  /// fontFamily: Pretendard
  /// fontWeight: 700
  /// color: GrayscaleGray700
  /// textAlign: Center
  static const TextStyle applicationCompleteModal = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.1875, // 19sp / 16sp = 118.75%
    letterSpacing: 0,
    color: Color(0xFF616161), // GrayscaleGray700
    fontFamily: 'Pretendard',
  );

  /// 검색 필드 지역명 텍스트 스타일
  /// Text/Body/S-Medium
  /// fontSize: 12.sp
  /// lineHeight: 14.sp
  /// fontFamily: Pretendard
  /// fontWeight: 500
  /// color: GrayscaleGray900
  static const TextStyle searchFieldRegion = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.16667, // 14sp / 12sp = 116.667%
    letterSpacing: 0,
    color: Color(0xFF1A1A1A), // GrayscaleGray900
    fontFamily: 'Pretendard',
  );

  /// 요일 드롭다운 텍스트 스타일
  /// fontSize: 12.sp
  /// lineHeight: 24.sp
  /// fontFamily: Pretendard
  /// fontWeight: 500
  /// color: GrayscaleGray50
  static const TextStyle dayDropdown = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 2.0, // 24sp / 12sp = 200%
    letterSpacing: 0,
    color: Color(0xFFFEFEFE), // GrayscaleGray50
    fontFamily: 'Pretendard',
  );

  /// 모달 타이틀 텍스트 스타일
  /// Text/Heading/H1-Bold
  /// fontSize: 16.sp
  /// lineHeight: 20.sp
  /// fontFamily: Pretendard
  /// fontWeight: 700
  /// color: GrayscaleGray700
  /// textAlign: Center
  static const TextStyle modalTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.25, // 20sp / 16sp = 125%
    letterSpacing: 0,
    color: Color(0xFF616161), // GrayscaleGray700
    fontFamily: 'Pretendard',
  );

  /// 모달 세부 타이틀 텍스트 스타일
  /// Text/Label/M-Bold
  /// fontSize: 10.sp
  /// lineHeight: 12.sp
  /// fontFamily: Pretendard
  /// fontWeight: 700
  /// color: NeutralIvory200
  /// textAlign: Center
  static const TextStyle modalSubtitle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.2, // 12sp / 10sp = 120%
    letterSpacing: 0,
    color: Color(0xFFF5E6D3), // NeutralIvory200
    fontFamily: 'Pretendard',
  );

  /// 모달 세부 본문 텍스트 스타일
  /// Text/Body/S-SemiBold
  /// fontSize: 12.sp
  /// lineHeight: 14.sp
  /// fontFamily: Pretendard
  /// fontWeight: 600
  /// color: GrayscaleGray600
  /// textAlign: Center
  static const TextStyle modalBody = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.16667, // 14sp / 12sp = 116.667%
    letterSpacing: 0,
    color: Color(0xFF6B7280), // GrayscaleGray600
    fontFamily: 'Pretendard',
  );

  /// 코스 타이틀 텍스트 스타일
  /// Text/Body/L-Semibold
  /// fontSize: 16.sp
  /// lineHeight: 24.sp
  /// fontFamily: Pretendard
  /// fontWeight: 600
  /// color: GrayscaleGray700
  static const TextStyle courseTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5, // 24sp / 16sp = 150%
    letterSpacing: 0,
    color: Color(0xFF616161), // GrayscaleGray700
    fontFamily: 'Pretendard',
  );

  /// 코스 세부 텍스트 스타일
  /// Text/Body/S-Medium
  /// fontSize: 12.sp
  /// lineHeight: 14.sp
  /// fontFamily: Pretendard
  /// fontWeight: 500
  /// color: GrayscaleGray600
  static const TextStyle courseDetail = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.16667, // 14sp / 12sp = 116.667%
    letterSpacing: 0,
    color: Color(0xFF6B7280), // GrayscaleGray600
    fontFamily: 'Pretendard',
  );

  /// 앱바 상단 문구 텍스트 스타일
  /// Text/Heading/H1-Bold
  /// fontSize: 16.sp
  /// lineHeight: 20.sp
  /// fontFamily: Pretendard
  /// fontWeight: 700
  /// color: PrimaryOrange500
  /// textAlign: Center
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.25, // 20sp / 16sp = 125%
    letterSpacing: 0,
    color: Color(0xFFFFA550), // PrimaryOrange500
    fontFamily: 'Pretendard',
  );

  /// 구분선 텍스트 스타일
  /// Text/Body/S-Medium
  /// fontSize: 12.sp
  /// lineHeight: 14.sp
  /// fontFamily: Pretendard
  /// fontWeight: 500
  /// color: Orange-400
  static const TextStyle dividerText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.16667, // 14sp / 12sp = 116.667%
    letterSpacing: 0,
    color: Color(0xFFFB923C), // Orange-400
    fontFamily: 'Pretendard',
  );
}
