import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/token_manager.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'base_viewmodel.dart';

class LoginViewModel extends BaseViewModel {
  
  // TextEditingController들
  final TextEditingController idController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  
  // 비밀번호 표시 상태
  bool _isPasswordVisible = false;
  
  // Getters
  bool get isPasswordVisible => _isPasswordVisible;
  
  // 비밀번호 표시 토글
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }
  
  
  // 일반 로그인 처리
  Future<bool> handleLogin(BuildContext context) async {
    setLoading(true);
    clearError();
    
    try {
      // 입력값 검증
      if (idController.text.trim().isEmpty) {
        setError('아이디를 입력해주세요.');
        return false;
      }
      
      if (pwController.text.trim().isEmpty) {
        setError('비밀번호를 입력해주세요.');
        return false;
      }
      
      // API 호출
      final result = await ApiService.login(
        userId: idController.text.trim(),
        password: pwController.text.trim(),
      );
      
      // 응답 처리
      if (result.containsKey('message') && !result.containsKey('code')) {
        // 200 OK - 로그인 성공
        final accessToken = result['accessToken'];
        final refreshToken = result['refreshToken'];
        final userId = result['userId'];
        final name = result['name'];
        final expiresIn = result['expiresIn'] ?? 3600;
        
        // 토큰 저장
        await AppTokenManager.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiresIn: expiresIn,
          userId: userId,
          userName: name,
        );
        
        return true; // 성공
      } else if (result['code'] == 'UNAUTHORIZED') {
        // 401 Unauthorized - 잘못된 아이디/비밀번호
        setError('아이디 또는 비밀번호가 올바르지 않습니다.');
        return false;
      } else {
        // 기타 오류
        setError(result['message'] ?? '로그인에 실패했습니다.');
        return false;
      }
    } catch (e) {
      setError('로그인 중 오류가 발생했습니다: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
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
      return await _processKakaoLogin(token, context);
    } on KakaoException catch (e) {
      if (e.toString().contains('userCancelled')) {
        // 사용자가 취소한 경우
        return false;
      } else {
        // 카카오톡 로그인 실패 시 카카오 계정으로 로그인 시도
        return await _loginWithKakaoAccount(context);
      }
    }
  }
  
  // 카카오 계정으로 로그인
  Future<bool> _loginWithKakaoAccount(BuildContext context) async {
    try {
      final OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
      return await _processKakaoLogin(token, context);
    } on KakaoException catch (e) {
      if (e.toString().contains('userCancelled')) {
        // 사용자가 취소한 경우
        return false;
      } else {
        setError('카카오 로그인에 실패했습니다: ${e.toString()}');
        return false;
      }
    }
  }
  
  // 카카오 로그인 처리
  Future<bool> _processKakaoLogin(OAuthToken token, BuildContext context) async {
    try {
      // 사용자 정보 가져오기
      final User user = await UserApi.instance.me();
      
      // 서버에 카카오 로그인 요청 (카카오 access token 전송)
      final result = await ApiService.kakaoLogin(code: token.accessToken);
      
      // API 명세서에 따른 응답 처리
      if (result.containsKey('message') && !result.containsKey('code')) {
        // 200 OK - 카카오 로그인 성공
        final accessToken = result['accessToken'];
        final refreshToken = result['refreshToken'];
        final userId = result['userId'];
        final name = result['name'] ?? user.kakaoAccount?.profile?.nickname ?? '카카오사용자';
        final expiresIn = result['expiresIn'] ?? 3600;
        
        // 토큰 저장
        await AppTokenManager.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiresIn: expiresIn,
          userId: userId,
          userName: name,
        );
        
        return true; // 성공
      } else if (result['code'] == 'BAD_REQUEST') {
        // 400 Bad Request - 유효하지 않은 인가 코드
        setError(result['message']);
        return false;
      } else {
        // 기타 오류
        setError(result['message'] ?? '카카오 로그인에 실패했습니다.');
        return false;
      }
    } catch (e) {
      setError('사용자 정보를 가져오는 중 오류가 발생했습니다: ${e.toString()}');
      return false;
    }
  }
  
  
  @override
  void dispose() {
    idController.dispose();
    pwController.dispose();
    super.dispose();
  }
}
