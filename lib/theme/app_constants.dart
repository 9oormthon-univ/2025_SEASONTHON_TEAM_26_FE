/// 앱에서 사용하는 모든 상수를 정의하는 클래스
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // Spacing (간격)
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border Radius (모서리 둥글기)
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusCircular = 50.0;

  // Elevation (그림자 높이)
  static const double elevationNone = 0.0;
  static const double elevationXS = 1.0;
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  static const double elevationXL = 16.0;

  // Icon Sizes (아이콘 크기)
  static const double iconXS = 16.0;
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 40.0;
  static const double iconXXL = 48.0;

  // Button Dimensions (버튼 크기)
  static const double buttonWidth = 334.0;
  static const double buttonHeight = 48.0;
  static const double buttonHeightS = 32.0;
  static const double buttonHeightM = 40.0;
  static const double buttonHeightL = 48.0;
  static const double buttonHeightXL = 56.0;

  // Input Field Dimensions (입력 필드 크기)
  static const double inputFieldWidth = 334.0;
  static const double inputFieldHeight = 44.0;
  
  // Modal Dimensions (모달 크기)
  static const double modalWidth = 300.0;
  static const double modalHeight = 320.0;
  
  // Modal Button Dimensions (모달 버튼 크기)
  static const double modalButtonWidth = 268.0;
  static const double modalButtonHeight = 48.0;
  
  // Search Screen Dimensions (검색 화면 크기)
  static const double searchFieldWidth = 282.0;
  static const double searchFieldHeight = 44.0;
  static const double searchCardWidth = 334.0;
  static const double searchCardHeight = 520.0; // 카드 높이를 늘려서 검색 필드와 붙게 함
  
  // Application Status Card Dimensions (신청 현황 카드 크기)
  static const double applicationStatusCardWidth = 334.0;
  static const double applicationStatusCardHeight = 404.0;
  static const double inputHeightS = 40.0;
  static const double inputHeightM = 48.0;
  static const double inputHeightL = 56.0;

  // App Bar Heights (앱바 높이)
  static const double appBarHeight = 56.0;
  static const double appBarHeightLarge = 80.0;

  // Bottom Navigation Heights (하단 네비게이션 높이)
  static const double bottomNavHeight = 60.0;

  // Card Dimensions (카드 크기)
  static const double cardMinHeight = 80.0;
  static const double cardMaxWidth = 400.0;

  // Animation Durations (애니메이션 지속시간)
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Breakpoints (반응형 브레이크포인트)
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // Z-Index (레이어 순서)
  static const int zIndexDropdown = 1000;
  static const int zIndexModal = 2000;
  static const int zIndexToast = 3000;
  static const int zIndexLoading = 4000;

  // API Constants (API 상수)
  static const int apiTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;

  // Validation Constants (유효성 검사 상수)
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;

  // Pagination Constants (페이지네이션 상수)
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // File Upload Constants (파일 업로드 상수)
  static const int maxFileSizeMB = 10;
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx', 'txt'];
}
