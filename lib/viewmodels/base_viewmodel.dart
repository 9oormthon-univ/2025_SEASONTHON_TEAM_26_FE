import 'package:flutter/material.dart';
import '../theme/app_constants.dart';
import '../theme/app_text_styles.dart';

/// 모든 ViewModel의 기본 클래스
/// 공통 기능들을 제공합니다.
abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 로딩 상태 설정
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 에러 메시지 설정
  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // 에러 메시지 초기화
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // 에러 다이얼로그 표시
  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('오류'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 성공 다이얼로그 표시
  void showSuccessDialog(BuildContext context, String message, [VoidCallback? onConfirm]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: AppConstants.modalWidth,
            height: AppConstants.modalHeight,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 그룸 이미지 (상단)
                Container(
                  width: 60,
                  height: 40,
                  child: Image.asset(
                    'assets/images/groom.png',
                    fit: BoxFit.contain,
                  ),
                ),
                
                // 버스 프론트 이미지 (중앙)
                Container(
                  width: 80,
                  height: 60,
                  child: Image.asset(
                    'assets/images/bus_front.png',
                    fit: BoxFit.contain,
                  ),
                ),
                
                // 성공 메시지
                Text(
                  message,
                  style: AppTextStyles.applicationCompleteModal,
                  textAlign: TextAlign.center,
                ),
                
                // 확인 버튼
                Container(
                  width: AppConstants.modalButtonWidth,
                  height: AppConstants.modalButtonHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (onConfirm != null) {
                        onConfirm();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF97316),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '확인',
                      style: AppTextStyles.customButton,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 확인 다이얼로그 표시
  Future<bool> showConfirmDialog(BuildContext context, String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  void dispose() {
    clearError();
    super.dispose();
  }
}
