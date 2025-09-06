import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AppTokenManager {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';

  // 토큰 저장
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
    String? userId,
    String? userName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 토큰 만료 시간 계산 (현재 시간 + expiresIn 초)
    final expiryTime = DateTime.now().add(Duration(seconds: expiresIn)).millisecondsSinceEpoch;
    
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setInt(_tokenExpiryKey, expiryTime);
    
    if (userId != null) {
      await prefs.setString(_userIdKey, userId);
    }
    if (userName != null) {
      await prefs.setString(_userNameKey, userName);
    }
  }

  // Access Token 가져오기
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Refresh Token 가져오기
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // 사용자 ID 가져오기
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // 사용자 이름 가져오기
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  // 토큰 만료 여부 확인
  static Future<bool> isTokenExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTime = prefs.getInt(_tokenExpiryKey);
    
    if (expiryTime == null) return true;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    return now >= expiryTime;
  }

  // 유효한 Access Token 가져오기 (자동 갱신 포함)
  static Future<String?> getValidAccessToken() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    
    if (accessToken == null || refreshToken == null) {
      return null;
    }

    // 토큰이 만료되지 않았으면 그대로 반환
    if (!await isTokenExpired()) {
      return accessToken;
    }

    // 토큰이 만료되었으면 재발급 시도
    try {
      final result = await ApiService.refreshToken(refreshToken: refreshToken);
      
      if (result.containsKey('accessToken') && !result.containsKey('code')) {
        // 토큰 재발급 성공
        final newAccessToken = result['accessToken'];
        final newRefreshToken = result['refreshToken'];
        final expiresIn = result['expiresIn'] ?? 3600;
        
        // 새로운 토큰 저장
        await saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
          expiresIn: expiresIn,
        );
        
        return newAccessToken;
      } else {
        // 토큰 재발급 실패 - 로그아웃 처리
        await clearTokens();
        return null;
      }
    } catch (e) {
      // 네트워크 오류 등 - 기존 토큰 반환
      return accessToken;
    }
  }

  // 토큰 삭제 (로그아웃)
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tokenExpiryKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
  }

  // 로그인 상태 확인
  static Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    
    if (accessToken == null || refreshToken == null) {
      return false;
    }

    // 토큰이 만료되었으면 재발급 시도
    if (await isTokenExpired()) {
      final validToken = await getValidAccessToken();
      return validToken != null;
    }

    return true;
  }

  // Authorization 헤더 생성
  static Future<Map<String, String>> getAuthHeaders() async {
    final accessToken = await getValidAccessToken();
    
    if (accessToken != null) {
      return {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };
    } else {
      return {
        'Content-Type': 'application/json',
      };
    }
  }
}
