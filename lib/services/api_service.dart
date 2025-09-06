import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import '../models/region.dart';
import '../models/bus_application_summary.dart';
import 'dio_service.dart';

class ApiService {
  static const String baseUrl = 'https://two025-seasonthon-team-26-be.onrender.com/api'; // 로컬 백엔드 서버 URL
  

  // 지역 검색 API - 백엔드 연동 (계층형)
  static Future<RegionSearchResponse> searchRegions({
    required String q,
    int? depth,
    int? limit,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'q': q,
      };
      
      if (depth != null) {
        queryParams['depth'] = depth.toString();
      }
      
      if (limit != null) {
        queryParams['limit'] = limit.toString();
      }

      print('🔍 지역 검색 API 호출: /regions/search');
      print('🔍 파라미터: $queryParams');
      
      final response = await DioService.get('/regions/search', queryParameters: queryParams);
      
      print('🔍 응답 데이터: ${response.data}');
      print('🔍 응답 상태 코드: ${response.statusCode}');
      
      return RegionSearchResponse.fromJson(response.data);
    } catch (e) {
      print('❌ 지역 검색 API 오류: $e');
      throw Exception('Error searching regions: $e');
    }
  }

  // 버스 신청 현황 API - 백엔드 연동
  static Future<BusApplicationSummary> getBusApplicationSummary({
    required String regionId,
    String? date,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'regionId': regionId,
      };
      
      if (date != null) {
        queryParams['date'] = date;
      }

      print('🔍 버스 신청 현황 API 호출: /applications/summary');
      print('🔍 파라미터: $queryParams');
      
      final response = await DioService.get('/applications/summary', queryParameters: queryParams);
      
      print('🔍 응답 데이터: ${response.data}');
      print('🔍 응답 상태 코드: ${response.statusCode}');
      
      return BusApplicationSummary.fromJson(response.data);
    } catch (e) {
      print('❌ 버스 신청 현황 API 오류: $e');
      throw Exception('Error loading bus application summary: $e');
    }
  }

  // 로그인 API - 백엔드 연동
  static Future<Map<String, dynamic>> login({
    required String loginId,
    required String password,
  }) async {
    try {
      final response = await DioService.post('/auth/login', data: {
        'loginId': loginId,
        'password': password,
      });

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return {
          'code': 'UNAUTHORIZED',
          'message': e.response?.data['message'] ?? '아이디 또는 비밀번호가 일치하지 않습니다.',
        };
      } else {
        return {
          'code': 'NETWORK_ERROR',
          'message': '네트워크 오류가 발생했습니다: ${e.message}',
        };
      }
    } catch (e) {
      return {
        'code': 'UNKNOWN_ERROR',
        'message': '로그인에 실패했습니다: $e',
      };
    }
  }

  // 아이디 중복 검사 API - 백엔드 연동
  static Future<Map<String, dynamic>> checkUsernameAvailability({
    required String username,
  }) async {
    try {
      final response = await DioService.get('/auth/check-username', queryParameters: {
        'username': username,
      });

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return {
          'available': false,
          'message': '이미 사용 중인 아이디입니다.',
        };
      } else {
        return {
          'available': false,
          'message': '아이디 중복 검사 중 오류가 발생했습니다.',
        };
      }
    } catch (e) {
      return {
        'available': false,
        'message': '네트워크 오류가 발생했습니다.',
      };
    }
  }

  // 회원가입 API - 백엔드 연동
  static Future<Map<String, dynamic>> signup({
    required String name,
    required String loginId,
    required String password,
    required String email,
  }) async {
    try {
      final response = await DioService.post('/auth/register', data: {
        'name': name,
        'loginId': loginId,
        'password': password,
        'email': email,
      });

      print('🔍 회원가입 응답 데이터: ${response.data}');
      print('🔍 응답 데이터 타입: ${response.data.runtimeType}');
      
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return {
          'code': 'BAD_REQUEST',
          'message': e.response?.data['message'] ?? '필수 입력 항목이 누락되었습니다.',
        };
      } else if (e.response?.statusCode == 409) {
        return {
          'code': 'CONFLICT',
          'message': e.response?.data['message'] ?? '이미 사용 중인 아이디입니다.',
        };
      } else {
        return {
          'code': 'NETWORK_ERROR',
          'message': '네트워크 오류가 발생했습니다: ${e.message}',
        };
      }
    } catch (e) {
      print('❌ 회원가입 일반 예외 발생: $e');
      print('❌ 예외 타입: ${e.runtimeType}');
      return {
        'code': 'UNKNOWN_ERROR',
        'message': '회원가입에 실패했습니다: $e',
      };
    }
  }

  // 카카오 로그인 API - 백엔드 연동
  static Future<Map<String, dynamic>> kakaoLogin({
    required String code,
  }) async {
    try {
      final response = await DioService.post('/auth/auth/kakao', data: {
        'accessToken': code,
      });

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return {
          'code': 'BAD_REQUEST',
          'message': e.response?.data['message'] ?? '유효하지 않은 인가 코드입니다.',
        };
      } else {
        return {
          'code': 'NETWORK_ERROR',
          'message': '네트워크 오류가 발생했습니다: ${e.message}',
        };
      }
    } catch (e) {
      return {
        'code': 'UNKNOWN_ERROR',
        'message': '카카오 로그인에 실패했습니다: $e',
      };
    }
  }

  // 토큰 재발급 API (테스트용 - 실제 API 연결 전까지)
  static Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
  }) async {
    // 실제 API 연결 전까지 테스트용 데이터 사용
    await Future.delayed(Duration(milliseconds: 300)); // 로딩 시뮬레이션
    
    // 테스트용 refresh token 검증
    if (refreshToken.isEmpty || refreshToken == 'invalid_refresh_token' || refreshToken == 'expired_refresh_token') {
      // 401 Unauthorized - 유효하지 않거나 만료된 리프레시 토큰
      return {
        'code': 'UNAUTHORIZED',
        'message': '유효하지 않거나 만료된 리프레시 토큰입니다.',
      };
    }
    
    // 200 OK - 토큰 재발급 성공
    return {
      'accessToken': 'eyJhbGci0iJIJ9.new_access_token_${DateTime.now().millisecondsSinceEpoch}',
      'refreshToken': 'eyJhbGCJ9.new_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      'tokenType': 'Bearer',
      'expiresIn': 3600,
    };

    /* 실제 API 연결 시 사용할 코드
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/token/refresh'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'refreshToken': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData;
      } else if (response.statusCode == 401) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        return {
          'code': 'UNAUTHORIZED',
          'message': errorData['message'] ?? '유효하지 않거나 만료된 리프레시 토큰입니다.',
        };
      } else {
        return {
          'code': 'UNKNOWN_ERROR',
          'message': '토큰 재발급에 실패했습니다.',
        };
      }
    } catch (e) {
      return {
        'code': 'NETWORK_ERROR',
        'message': '네트워크 오류가 발생했습니다.',
      };
    }
    */
  }

  // 버스 신청 API - 백엔드 연동
  static Future<Map<String, dynamic>> createBusApplication({
    required String regionId,
    required String name,
    required int age,
    required String phoneNumber,
    required String address,
    required String selectedProgram,
    required String desiredBook,
  }) async {
    try {
      final response = await DioService.post('/applications', data: {
        'regionId': regionId,
        'name': name,
        'age': age,
        'phoneNumber': phoneNumber,
        'address': address,
        'selectedProgram': selectedProgram,
        'desiredBook': desiredBook,
      });

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return {
          'code': 'BAD_REQUEST',
          'message': e.response?.data['message'] ?? '잘못된 요청입니다.',
        };
      } else if (e.response?.statusCode == 409) {
        return {
          'code': 'CONFLICT',
          'message': e.response?.data['message'] ?? '이미 신청한 사용자입니다.',
        };
      } else {
        return {
          'code': 'NETWORK_ERROR',
          'message': '네트워크 오류가 발생했습니다: ${e.message}',
        };
      }
    } catch (e) {
      return {
        'code': 'UNKNOWN_ERROR',
        'message': '버스 신청에 실패했습니다: $e',
      };
    }
  }
}
