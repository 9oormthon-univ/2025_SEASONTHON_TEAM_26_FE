import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_constants.dart';
import 'app_shadows.dart';

/// 앱에서 사용하는 커스텀 위젯 스타일을 정의하는 클래스
class AppWidgetStyles {
  // Private constructor to prevent instantiation
  AppWidgetStyles._();

  // Container Styles (컨테이너 스타일)
  static BoxDecoration get cardContainer => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppConstants.radiusM),
    boxShadow: AppShadows.card,
  );

  static BoxDecoration get primaryContainer => BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(AppConstants.radiusM),
    boxShadow: AppShadows.button,
  );

  static BoxDecoration get secondaryContainer => BoxDecoration(
    color: AppColors.secondary,
    borderRadius: BorderRadius.circular(AppConstants.radiusM),
    boxShadow: AppShadows.button,
  );

  static BoxDecoration get inputContainer => BoxDecoration(
    color: AppColors.surfaceVariant,
    borderRadius: BorderRadius.circular(AppConstants.radiusM),
    border: Border.all(color: AppColors.grey300),
  );

  static BoxDecoration get inputContainerFocused => BoxDecoration(
    color: AppColors.surfaceVariant,
    borderRadius: BorderRadius.circular(AppConstants.radiusM),
    border: Border.all(color: AppColors.primary, width: 2),
  );

  static BoxDecoration get inputContainerError => BoxDecoration(
    color: AppColors.surfaceVariant,
    borderRadius: BorderRadius.circular(AppConstants.radiusM),
    border: Border.all(color: AppColors.error, width: 2),
  );

  // Button Styles (버튼 스타일)
  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.white,
    elevation: AppConstants.elevationS,
    padding: const EdgeInsets.symmetric(
      horizontal: AppConstants.spacingL,
      vertical: AppConstants.spacingM,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
    ),
    textStyle: AppTextStyles.buttonMedium,
    minimumSize: const Size(0, AppConstants.buttonHeightL),
  );

  static ButtonStyle get secondaryButton => OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: const BorderSide(color: AppColors.primary),
    padding: const EdgeInsets.symmetric(
      horizontal: AppConstants.spacingL,
      vertical: AppConstants.spacingM,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
    ),
    textStyle: AppTextStyles.buttonMedium,
    minimumSize: const Size(0, AppConstants.buttonHeightL),
  );

  static ButtonStyle get textButton => TextButton.styleFrom(
    foregroundColor: AppColors.primary,
    padding: const EdgeInsets.symmetric(
      horizontal: AppConstants.spacingM,
      vertical: AppConstants.spacingS,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.radiusS),
    ),
    textStyle: AppTextStyles.buttonMedium,
  );

  // Input Field Styles (입력 필드 스타일)
  static InputDecoration get inputDecoration => InputDecoration(
    filled: true,
    fillColor: AppColors.surfaceVariant,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
      borderSide: const BorderSide(color: AppColors.error, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppConstants.spacingM,
      vertical: AppConstants.spacingM,
    ),
    hintStyle: AppTextStyles.hint,
    labelStyle: AppTextStyles.labelMedium,
    errorStyle: AppTextStyles.error,
  );

  // Card Styles (카드 스타일)
  static CardTheme get cardTheme => CardTheme(
    color: AppColors.surface,
    elevation: AppConstants.elevationS,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
    ),
    margin: const EdgeInsets.all(AppConstants.spacingS),
  );

  // App Bar Styles (앱바 스타일)
  static AppBarTheme get appBarTheme => const AppBarTheme(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.textPrimary,
    elevation: AppConstants.elevationS,
    centerTitle: true,
    titleTextStyle: AppTextStyles.headline6,
  );

  // Bottom Navigation Styles (하단 네비게이션 스타일)
  static BottomNavigationBarThemeData get bottomNavTheme => const BottomNavigationBarThemeData(
    backgroundColor: AppColors.surface,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textSecondary,
    type: BottomNavigationBarType.fixed,
    elevation: AppConstants.elevationM,
  );

  // Search Field Styles (검색 필드 스타일)
  static BoxDecoration get searchFieldContainer => BoxDecoration(
    color: AppColors.surfaceVariant, // Gray-50
    borderRadius: BorderRadius.circular(12), // 12dp 둥글기
  );

  static EdgeInsets get searchFieldPadding => const EdgeInsets.symmetric(
    horizontal: 12, // 좌우 12dp
    vertical: 10,   // 상하 10dp
  );

  static InputDecoration get searchFieldDecoration => InputDecoration(
    hintStyle: const TextStyle(
      color: AppColors.textHint, // Gray-300
      fontSize: 16,
    ),
    border: InputBorder.none,
    contentPadding: EdgeInsets.zero,
    isDense: true,
  );

  static TextStyle get searchFieldTextStyle => const TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
  );

  // Search Field Dimensions (검색 필드 크기)
  static const double searchFieldWidth = 334.0; // 334dp
  static const double searchFieldHeight = 44.0; // 44dp

  // Button Styles (버튼 스타일)
  static BoxDecoration get primaryButtonContainer => BoxDecoration(
    color: AppColors.primary, // Orange-500
    borderRadius: BorderRadius.circular(16), // 16dp 둥글기
  );

  static EdgeInsets get primaryButtonPadding => const EdgeInsets.symmetric(
    horizontal: 15, // 좌우 15dp
    vertical: 17,   // 상하 17dp
  );

  static TextStyle get primaryButtonTextStyle => const TextStyle(
    color: AppColors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // Button Dimensions (버튼 크기)
  static const double primaryButtonWidth = 334.0; // 334dp
  static const double primaryButtonHeight = 48.0; // 48dp

  // App Bar Button Styles (앱바 버튼 스타일)
  static BoxDecoration get appBarButtonContainer => BoxDecoration(
    color: AppColors.primary, // Orange-500
    borderRadius: BorderRadius.circular(20), // 20dp 둥글기
  );

  // App Bar Button Dimensions (앱바 버튼 크기)
  static const double appBarButtonWidth = 160.0; // 160dp
  static const double appBarButtonHeight = 40.0; // 40dp

  // Bus Application Search Field Styles (버스 신청 검색 필드 스타일)
  static BoxDecoration get busSearchFieldContainer => BoxDecoration(
    color: AppColors.surfaceVariant, // Gray-50
    borderRadius: BorderRadius.circular(16), // 16dp 둥글기
    boxShadow: [
      BoxShadow(
        color: const Color(0x1AFFB06F), // Orange-300 with 10% opacity
        offset: const Offset(0, 4),
        blurRadius: 10,
        spreadRadius: 0,
      ),
    ],
  );

  static EdgeInsets get busSearchFieldPadding => const EdgeInsets.only(
    left: 20,   // 좌 20dp
    top: 13,    // 상 13dp
    right: 101, // 우 101dp
    bottom: 13, // 하 13dp
  );

  // Bus Application Search Field Dimensions (버스 신청 검색 필드 크기)
  static const double busSearchFieldWidth = 282.0; // 282dp
  static const double busSearchFieldHeight = 44.0; // 44dp

  // Bus Application Card Styles (버스 신청 카드 스타일)
  static BoxDecoration get busApplicationCardContainer => BoxDecoration(
    color: AppColors.surface, // Ivory-200
    borderRadius: BorderRadius.circular(15), // 15dp 둥글기
    boxShadow: [
      BoxShadow(
        color: const Color(0x1AFFB06F), // Orange-300 with 10% opacity
        offset: const Offset(0, 4),
        blurRadius: 10,
        spreadRadius: 0,
      ),
    ],
  );

  // Bus Application Card Dimensions (버스 신청 카드 크기)
  static const double busApplicationCardWidth = 334.0; // 334dp
  static const double busApplicationCardHeight = 480.0; // 480dp (검색 전)
  static const double busApplicationCardHeightAfterSearch = 404.0; // 404dp (검색 후)

  // Application Complete Popup Styles (신청 완료 팝업 스타일)
  static BoxDecoration get applicationCompletePopupContainer => BoxDecoration(
    color: AppColors.surfaceVariant, // Gray-50
    borderRadius: BorderRadius.circular(20), // 20dp 둥글기
  );

  static EdgeInsets get applicationCompletePopupPadding => const EdgeInsets.symmetric(
    horizontal: 16, // 좌우 16dp
    vertical: 20,   // 상하 20dp
  );

  // Application Complete Popup Dimensions (신청 완료 팝업 크기)
  static const double applicationCompletePopupWidth = 312.0; // 312dp
  static const double applicationCompletePopupHeight = 257.0; // 257dp

  // Popup Button Styles (팝업 버튼 스타일)
  static BoxDecoration get popupButtonContainer => BoxDecoration(
    color: AppColors.primary, // Orange-500
    borderRadius: BorderRadius.circular(16), // 16dp 둥글기
  );

  static EdgeInsets get popupButtonPadding => const EdgeInsets.symmetric(
    horizontal: 94, // 좌우 94dp
    vertical: 10,   // 상하 10dp
  );

  static TextStyle get popupButtonTextStyle => const TextStyle(
    color: AppColors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // Popup Button Dimensions (팝업 버튼 크기)
  static const double popupButtonWidth = 280.0; // 280dp
  static const double popupButtonHeight = 46.0; // 46dp

  // Bus Status Search Field Styles (버스 현황 검색 필드 스타일)
  static BoxDecoration get busStatusSearchFieldContainer => BoxDecoration(
    color: AppColors.surfaceVariant, // Gray-50
    borderRadius: BorderRadius.circular(20), // 20dp 둥글기
    border: Border.all(
      color: AppColors.primaryDisabled, // Orange-200
      width: 1, // 1dp
    ),
    boxShadow: [
      BoxShadow(
        color: const Color(0x1AFFB06F), // Orange-300 with 10% opacity
        offset: const Offset(0, 4),
        blurRadius: 10,
        spreadRadius: 0,
      ),
    ],
  );

  static EdgeInsets get busStatusSearchFieldPadding => const EdgeInsets.only(
    left: 20,   // 좌 20dp
    top: 13,    // 상 13dp
    right: 101, // 우 101dp
    bottom: 13, // 하 13dp
  );

  // Bus Status Search Field Dimensions (버스 현황 검색 필드 크기)
  static const double busStatusSearchFieldWidth = 248.0; // 248dp
  static const double busStatusSearchFieldHeight = 44.0; // 44dp

  // Modal Styles (모달 스타일)
  static BoxDecoration get modalContainer => BoxDecoration(
    color: AppColors.surface, // Ivory-200
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(30),  // 상단 좌측 30dp
      topRight: Radius.circular(30), // 상단 우측 30dp
      bottomLeft: Radius.circular(0), // 하단 좌측 0dp
      bottomRight: Radius.circular(0), // 하단 우측 0dp
    ),
    boxShadow: [
      BoxShadow(
        color: const Color(0x33FFB06F), // Orange-300 with 20% opacity
        offset: const Offset(0, 8),
        blurRadius: 20,
        spreadRadius: 0,
      ),
    ],
  );

  // Modal Dimensions (모달 크기)
  static const double modalWidth = 390.0; // 390dp
  static const double modalHeight = 253.0; // 253dp
}
