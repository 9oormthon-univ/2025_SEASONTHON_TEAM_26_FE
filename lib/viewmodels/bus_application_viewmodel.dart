import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'base_viewmodel.dart';

class BusApplicationViewModel extends BaseViewModel {
  // TextEditingController들
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController desiredBookController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // 상태 변수들
  String? _selectedProgram;
  final List<String> _programs = [
    '어린이 독서 프로그램',
    '청소년 독서 클럽',
    '성인 독서 모임',
    '독서 토론회',
    '작가와의 만남',
    '독서 감상문 쓰기',
    '독서 퀴즈 대회',
  ];

  // Getters
  String? get selectedProgram => _selectedProgram;
  List<String> get programs => _programs;

  // 프로그램 선택
  void setSelectedProgram(String? program) {
    _selectedProgram = program;
    notifyListeners();
  }

  // 주소 검색 버튼 클릭 시 호출되는 메서드 (현재는 기능 없음)
  Future<void> handleAddressSearch(BuildContext context) async {
    // 주소 검색 기능이 제거됨 - 직접 입력만 가능
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('주소를 직접 입력해주세요.')),
    );
  }

  // 버스 신청 처리
  Future<bool> handleBusApplication(BuildContext context, {
    required String regionId,
    required String regionName,
    required Map<String, double> center,
  }) async {
    setLoading(true);
    clearError();

    try {
      // 폼 검증
      if (!formKey.currentState!.validate()) {
        return false;
      }

      // API 호출
      final result = await ApiService.createBusApplication(
        regionId: regionId,
        name: nameController.text.trim(),
        age: int.parse(ageController.text.trim()),
        phoneNumber: phoneNumberController.text.trim(),
        address: addressController.text.trim(),
        selectedProgram: _selectedProgram ?? '', // 선택사항
        desiredBook: desiredBookController.text.trim(),
      );

      // 응답 처리
      if (result.containsKey('message') && !result.containsKey('code')) {
        // 200 OK - 신청 성공
        showSuccessDialog(context, result['message'], () {
          // 성공 다이얼로그 확인 후 신청 화면만 닫기 (BusApplicationStatusScreen의 .then() 콜백이 실행되도록)
          Navigator.pop(context); // 신청 화면 닫기
        });
        return true;
      } else if (result['code'] == 'BAD_REQUEST') {
        // 400 Bad Request - 필수 필드 누락
        setError(result['message']);
        return false;
      } else if (result['code'] == 'CONFLICT') {
        // 409 Conflict - 이미 신청한 사용자
        setError(result['message']);
        return false;
      } else {
        // 기타 오류
        setError(result['message'] ?? '버스 신청에 실패했습니다.');
        return false;
      }
    } catch (e) {
      setError('버스 신청 중 오류가 발생했습니다: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // 입력값 검증
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '이름을 입력해주세요.';
    }
    if (value.trim().length < 2) {
      return '이름은 2자 이상 입력해주세요.';
    }
    return null;
  }

  String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '나이를 입력해주세요.';
    }
    // 나이 형식 검사 제거 - 숫자만 입력하면 됨
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '전화번호를 입력해주세요.';
    }
    // 전화번호 형식 검사 제거 - 자유롭게 입력 가능
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '주소를 입력해주세요.';
    }
    return null;
  }

  String? validateDesiredBook(String? value) {
    // 희망 도서는 선택사항이므로 검증하지 않음
    return null;
  }

  // 폼 초기화
  void resetForm() {
    nameController.clear();
    ageController.clear();
    phoneNumberController.clear();
    addressController.clear();
    desiredBookController.clear();
    _selectedProgram = null;
    clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    desiredBookController.dispose();
    super.dispose();
  }
}
