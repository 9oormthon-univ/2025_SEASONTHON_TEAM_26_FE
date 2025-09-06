import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'bus_application_status_viewmodel.dart';
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
  Future<bool> handleBusApplication(
    BuildContext context, {
    required String regionId,
    required String regionName,
  }) async {
    setLoading(true);
    clearError();

    try {
      // 폼 검증
      if (!formKey.currentState!.validate()) {
        return false;
      }

      // 목업 신청 처리
      await Future.delayed(Duration(milliseconds: 500)); // 로딩 시뮬레이션
      
      // 신청 성공 시뮬레이션
      print('🎉 버스 신청 성공: $regionName, 신청자: ${nameController.text.trim()}');
      
      // 신청 현황 데이터 업데이트
      BusApplicationStatusViewModel.updateApplicationCount(regionId);
      
      showSuccessDialog(context, '버스 신청이 완료되었습니다!', () {
        Navigator.pop(context); // 신청 화면 닫기
      });
      return true;
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
