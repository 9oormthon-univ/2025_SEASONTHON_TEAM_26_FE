import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import '../services/api_service.dart';
import 'base_viewmodel.dart';

class SignupViewModel extends BaseViewModel {
  // TextEditingController들
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  final TextEditingController pwcheckController = TextEditingController();
  final TextEditingController emailPrefixController = TextEditingController();
  final TextEditingController customDomainController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // 상태 변수들
  String _selectedEmailDomain = 'naver.com';
  bool _isCustomDomain = false;
  bool _isCheckingUsername = false;
  bool _isUsernameAvailable = false;
  String? _usernameCheckMessage;
  bool _isPasswordVisible = false;
  bool _isPasswordCheckVisible = false;

  // Getters
  String get selectedEmailDomain => _selectedEmailDomain;
  bool get isCustomDomain => _isCustomDomain;
  bool get isCheckingUsername => _isCheckingUsername;
  bool get isUsernameAvailable => _isUsernameAvailable;
  String? get usernameCheckMessage => _usernameCheckMessage;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isPasswordCheckVisible => _isPasswordCheckVisible;

  // 이메일 도메인 설정
  void setEmailDomain(String domain) {
    if (domain == '직접 입력') {
      _isCustomDomain = true;
      _selectedEmailDomain = '';
    } else {
      _selectedEmailDomain = domain;
      _isCustomDomain = false;
    }
    notifyListeners();
  }

  
  // 비밀번호 표시 토글
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }
  
  // 비밀번호 확인 표시 토글
  void togglePasswordCheckVisibility() {
    _isPasswordCheckVisible = !_isPasswordCheckVisible;
    notifyListeners();
  }

  // 전체 이메일 주소 생성
  String getFullEmail() {
    if (_isCustomDomain) {
      return '${emailPrefixController.text}@${customDomainController.text}';
    } else {
      return '${emailPrefixController.text}@$_selectedEmailDomain';
    }
  }

  // 아이디 중복 검사
  Future<void> checkUsernameAvailability() async {
    if (idController.text.trim().isEmpty) {
      setError('아이디를 입력해주세요.');
      return;
    }

    _isCheckingUsername = true;
    _isUsernameAvailable = false;
    _usernameCheckMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.checkUsernameAvailability(
        username: idController.text.trim(),
      );

      if (result['available'] == true) {
        _isUsernameAvailable = true;
        _usernameCheckMessage = '사용 가능한 아이디입니다.';
      } else {
        _isUsernameAvailable = false;
        _usernameCheckMessage = result['message'] ?? '이미 사용 중인 아이디입니다.';
      }
    } catch (e) {
      _isUsernameAvailable = false;
      _usernameCheckMessage = '아이디 중복 검사 중 오류가 발생했습니다.';
      setError('아이디 중복 검사 중 오류가 발생했습니다: ${e.toString()}');
    } finally {
      _isCheckingUsername = false;
      notifyListeners();
    }
  }

  // 회원가입 처리
  Future<bool> handleSignup(BuildContext context) async {
    setLoading(true);
    clearError();

    try {
      // 폼 검증
      if (!formKey.currentState!.validate()) {
        return false;
      }

      // 아이디 중복 검사
      await checkUsernameAvailability();
      if (!_isUsernameAvailable) {
        setError('이미 사용 중인 아이디입니다.');
        return false;
      }

      // 비밀번호 확인
      if (pwController.text != pwcheckController.text) {
        setError('비밀번호가 일치하지 않습니다.');
        return false;
      }

      // 이메일 검증
      final email = getFullEmail();
      if (emailPrefixController.text.trim().isEmpty) {
        setError('이메일을 입력해주세요.');
        return false;
      }

      if (_isCustomDomain && customDomainController.text.trim().isEmpty) {
        setError('이메일 도메인을 입력해주세요.');
        return false;
      }

      // API 호출
      final result = await ApiService.signup(
        name: nameController.text.trim(),
        userId: idController.text.trim(),
        password: pwController.text.trim(),
        email: email,
      );

      // 응답 처리
      if (result.containsKey('message') && !result.containsKey('code')) {
        // 200 OK - 회원가입 성공
        showSuccessDialog(context, result['message'], () {
          // 성공 다이얼로그 확인 후 로그인 화면으로 이동
          Navigator.pop(context); // 다이얼로그 닫기
          Navigator.pop(context); // 회원가입 화면 닫기
        });
        return true;
      } else if (result['code'] == 'CONFLICT') {
        // 409 Conflict - 중복된 아이디
        setError(result['message']);
        return false;
      } else if (result['code'] == 'BAD_REQUEST') {
        // 400 Bad Request - 필수 필드 누락
        setError(result['message']);
        return false;
      } else {
        // 기타 오류
        setError(result['message'] ?? '회원가입에 실패했습니다.');
        return false;
      }
    } catch (e) {
      setError('회원가입 중 오류가 발생했습니다: ${e.toString()}');
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

  String? validateUserId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '아이디를 입력해주세요.';
    }
    // 길이 제한이나 문자 조합 조건 제거 - 중복 확인만 유지
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요.';
    }
    // 길이 제한 조건 제거 - 비밀번호 확인만 유지
    return null;
  }

  String? validatePasswordCheck(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호 확인을 입력해주세요.';
    }
    if (value != pwController.text) {
      return '비밀번호가 일치하지 않습니다.';
    }
    return null;
  }

  String? validateEmailPrefix(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '이메일을 입력해주세요.';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+$').hasMatch(value.trim())) {
      return '올바른 이메일 형식이 아닙니다.';
    }
    return null;
  }

  String? validateCustomDomain(String? value) {
    if (_isCustomDomain) {
      if (value == null || value.trim().isEmpty) {
        return '도메인을 입력해주세요.';
      }
      if (!RegExp(r'^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value.trim())) {
        return '올바른 도메인 형식이 아닙니다.';
      }
    }
    return null;
  }

  // 카카오 로그인 처리
  Future<bool> handleKakaoLogin(BuildContext context) async {
    setLoading(true);
    clearError();
    
    try {
      // 카카오톡이 설치되어 있는지 확인
      if (await isKakaoTalkInstalled()) {
        // 카카오톡으로 로그인
        return await _loginWithKakaoTalk(context);
      } else {
        // 카카오 계정으로 로그인
        return await _loginWithKakaoAccount(context);
      }
    } catch (e) {
      setError('카카오 로그인 중 오류가 발생했습니다: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // 카카오톡으로 로그인
  Future<bool> _loginWithKakaoTalk(BuildContext context) async {
    try {
      final OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
      return await _processKakaoLoginResult(context, token);
    } catch (e) {
      if (e is PlatformException && e.code == 'CANCELLED') {
        // 사용자가 취소한 경우
        return false;
      }
      // 카카오톡 로그인 실패 시 카카오 계정으로 로그인 시도
      return await _loginWithKakaoAccount(context);
    }
  }

  // 카카오 계정으로 로그인
  Future<bool> _loginWithKakaoAccount(BuildContext context) async {
    try {
      final OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
      return await _processKakaoLoginResult(context, token);
    } catch (e) {
      if (e is PlatformException && e.code == 'CANCELLED') {
        // 사용자가 취소한 경우
        return false;
      }
      setError('카카오 로그인에 실패했습니다.');
      return false;
    }
  }

  // 카카오 로그인 결과 처리
  Future<bool> _processKakaoLoginResult(BuildContext context, OAuthToken token) async {
    try {
      // 카카오 사용자 정보 가져오기
      final User user = await UserApi.instance.me();
      
      // 서버에 카카오 로그인 요청
      final result = await ApiService.kakaoLogin(code: token.accessToken);

      if (result.containsKey('accessToken')) {
        // 성공 - 토큰 저장
        final accessToken = result['accessToken'];
        final refreshToken = result['refreshToken'];
        final tokenType = result['tokenType'];
        final expiresIn = result['expiresIn'];
        final userId = result['userId'];
        final name = result['name'];

        // 토큰 저장 (실제로는 SecureStorage 사용)
        // await SecureStorage.storeTokens(accessToken, refreshToken, tokenType, expiresIn);
        
        showSuccessDialog(
          context,
          '${name}님, 환영합니다!',
          () {
            Navigator.pushReplacementNamed(context, '/bus-search');
          },
        );
        
        return true;
      } else {
        // 실패
        final errorCode = result['code'] ?? 'UNKNOWN_ERROR';
        final errorMessage = result['message'] ?? '카카오 로그인에 실패했습니다.';
        
        setError(errorMessage);
        return false;
      }
    } catch (e) {
      setError('카카오 로그인 처리 중 오류가 발생했습니다: ${e.toString()}');
      return false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    idController.dispose();
    pwController.dispose();
    pwcheckController.dispose();
    emailPrefixController.dispose();
    customDomainController.dispose();
    super.dispose();
  }
}
