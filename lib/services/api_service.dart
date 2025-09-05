import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/region.dart';
import '../models/bus_application_summary.dart';

class ApiService {
  static const String baseUrl = 'https://your-api-base-url.com'; // 실제 API URL로 변경
  
  // 테스트용 데이터 저장소 (실제로는 서버에서 관리)
  static Map<String, Map<String, dynamic>> _testData = {};
  
  // 테스트용 사용자 데이터 저장소 (회원가입한 사용자들)
  static Map<String, String> _registeredUsers = {
    'admin': 'password123',
    'user1': 'user123',
    'test': 'test123',
    'demo': 'demo123',
  };

  // 지역 검색 API (테스트용 - 실제 API 연결 전까지)
  static Future<RegionSearchResponse> searchRegions({
    required String keyword,
    int? limit,
  }) async {
    // 실제 API 연결 전까지 테스트용 데이터 사용
    await Future.delayed(Duration(milliseconds: 500)); // 로딩 시뮬레이션
    
    // 테스트용 지역 데이터
    final testRegions = [
      {
        'regionId': '1',
        'name': '서울특별시',
        'center': {'lat': 37.5665, 'lng': 126.9780}
      },
      {
        'regionId': '2', 
        'name': '부산광역시',
        'center': {'lat': 35.1796, 'lng': 129.0756}
      },
      {
        'regionId': '3',
        'name': '대구광역시', 
        'center': {'lat': 35.8714, 'lng': 128.6014}
      },
      {
        'regionId': '4',
        'name': '인천광역시',
        'center': {'lat': 37.4563, 'lng': 126.7052}
      },
      {
        'regionId': '5',
        'name': '광주광역시',
        'center': {'lat': 35.1595, 'lng': 126.8526}
      },
      {
        'regionId': '6',
        'name': '대전광역시',
        'center': {'lat': 36.3504, 'lng': 127.3845}
      },
      {
        'regionId': '7',
        'name': '울산광역시',
        'center': {'lat': 35.5384, 'lng': 129.3114}
      },
      {
        'regionId': '8',
        'name': '세종특별자치시',
        'center': {'lat': 36.4800, 'lng': 127.2890}
      },
    ];

    // 키워드로 필터링
    final filteredRegions = testRegions
        .where((region) => region['name'].toString().contains(keyword))
        .toList();

    // limit 적용
    final limitedRegions = limit != null 
        ? filteredRegions.take(limit).toList()
        : filteredRegions;

    return RegionSearchResponse(
      items: limitedRegions.map((region) => Region.fromJson(region)).toList(),
    );

    /* 실제 API 연결 시 사용할 코드
    try {
      final Map<String, String> queryParams = {
        'keyword': keyword,
      };
      
      if (limit != null) {
        queryParams['limit'] = limit.toString();
      }

      final uri = Uri.parse('$baseUrl/regions/search').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // 인증이 필요하다면 여기에 토큰 추가
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return RegionSearchResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load regions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching regions: $e');
    }
    */
  }

  // 버스 신청 현황 API (테스트용 - 실제 API 연결 전까지)
  static Future<BusApplicationSummary> getBusApplicationSummary({
    required String regionId,
    String? date,
  }) async {
    // 실제 API 연결 전까지 테스트용 데이터 사용
    await Future.delayed(Duration(milliseconds: 300)); // 로딩 시뮬레이션
    
    // 테스트용 데이터 - regionId에 따른 다른 데이터
    if (_testData.isEmpty) {
      _testData = {
      '1': { // 서울특별시
        'regionId': '1',
        'region_name': '서울특별시',
        'date': date ?? '2025-01-15',
        'capacity': 50,
        'appliedCount': 1,
        'remaining': 49,
        'fillRatePercent': 2.0,
      },
      '2': { // 부산광역시
        'regionId': '2',
        'region_name': '부산광역시',
        'date': date ?? '2025-01-15',
        'capacity': 50,
        'appliedCount': 2,
        'remaining': 48,
        'fillRatePercent': 4.0,
      },
      '3': { // 대구광역시
        'regionId': '3',
        'region_name': '대구광역시',
        'date': date ?? '2025-01-15',
        'capacity': 50,
        'appliedCount': 3,
        'remaining': 47,
        'fillRatePercent': 6.0,
      },
      '4': { // 인천광역시
        'regionId': '4',
        'region_name': '인천광역시',
        'date': date ?? '2025-01-15',
        'capacity': 50,
        'appliedCount': 4,
        'remaining': 46,
        'fillRatePercent': 8.0,
      },
      '5': { // 광주광역시
        'regionId': '5',
        'region_name': '광주광역시',
        'date': date ?? '2025-01-15',
        'capacity': 50,
        'appliedCount': 5,
        'remaining': 45,
        'fillRatePercent': 10.0,
      },
      '6': { // 대전광역시
        'regionId': '6',
        'region_name': '대전광역시',
        'date': date ?? '2025-01-15',
        'capacity': 50,
        'appliedCount': 6,
        'remaining': 44,
        'fillRatePercent': 12.0,
      },
      '7': { // 울산광역시
        'regionId': '7',
        'region_name': '울산광역시',
        'date': date ?? '2025-01-15',
        'capacity': 50,
        'appliedCount': 7,
        'remaining': 43,
        'fillRatePercent': 14.0,
      },
      '8': { // 세종특별자치시
        'regionId': '8',
        'region_name': '세종특별자치시',
        'date': date ?? '2025-01-15',
        'capacity': 50,
        'appliedCount': 8,
        'remaining': 42,
        'fillRatePercent': 16.0,
      },
      };
    }

    final data = _testData[regionId] ?? _testData['1']!; // 기본값은 서울
    return BusApplicationSummary.fromJson(data);

    /* 실제 API 연결 시 사용할 코드
    try {
      final Map<String, String> queryParams = {
        'regionId': regionId,
      };
      
      if (date != null) {
        queryParams['date'] = date;
      }

      final uri = Uri.parse('$baseUrl/applications/summary').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // 인증이 필요하다면 여기에 토큰 추가
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return BusApplicationSummary.fromJson(jsonData);
      } else {
        throw Exception('Failed to load bus application summary: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading bus application summary: $e');
    }
    */
  }

  // 로그인 API (테스트용 - 실제 API 연결 전까지)
  static Future<Map<String, dynamic>> login({
    required String userId,
    required String password,
  }) async {
    // 실제 API 연결 전까지 테스트용 데이터 사용
    await Future.delayed(Duration(milliseconds: 500)); // 로딩 시뮬레이션
    
    // 사용자 인증 확인 (등록된 사용자들 중에서)
    if (_registeredUsers.containsKey(userId) && _registeredUsers[userId] == password) {
      // 200 OK - 로그인 성공
      return {
        'message': '로그인 성공',
        'userId': userId,
        'accessToken': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test_access_token_${DateTime.now().millisecondsSinceEpoch}',
        'refreshToken': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        'tokenType': 'Bearer',
        'expiresIn': 3600,
      };
    } else {
      // 401 Unauthorized - 인증 실패
      return {
        'code': 'UNAUTHORIZED',
        'message': '아이디 또는 비밀번호가 일치하지 않습니다.',
      };
    }

    /* 실제 API 연결 시 사용할 코드
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': userId,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData;
      } else if (response.statusCode == 401) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        return {
          'code': 'UNAUTHORIZED',
          'message': errorData['message'] ?? '아이디 또는 비밀번호가 일치하지 않습니다.',
        };
      } else {
        return {
          'code': 'UNKNOWN_ERROR',
          'message': '로그인에 실패했습니다.',
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

  // 아이디 중복 검사 API (테스트용 - 실제 API 연결 전까지)
  static Future<Map<String, dynamic>> checkUsernameAvailability({
    required String username,
  }) async {
    // 실제 API 연결 전까지 테스트용 데이터 사용
    await Future.delayed(Duration(milliseconds: 300)); // 로딩 시뮬레이션
    
    // 중복 검사
    if (_registeredUsers.containsKey(username)) {
      return {
        'available': false,
        'message': '이미 사용 중인 아이디입니다.',
      };
    } else {
      return {
        'available': true,
        'message': '사용 가능한 아이디입니다.',
      };
    }

    /* 실제 API 연결 시 사용할 코드
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/check-username?username=$username'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData;
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
    */
  }

  // 회원가입 API (테스트용 - 실제 API 연결 전까지)
  static Future<Map<String, dynamic>> signup({
    required String name,
    required String userId,
    required String password,
    required String email,
  }) async {
    // 실제 API 연결 전까지 테스트용 데이터 사용
    await Future.delayed(Duration(milliseconds: 500)); // 로딩 시뮬레이션
    
    // 중복 검사 (409 Conflict)
    if (_registeredUsers.containsKey(userId)) {
      return {
        'code': 'CONFLICT',
        'message': '이미 사용 중인 아이디입니다.',
      };
    }
    
    // 회원가입 성공 - 사용자 정보 저장
    _registeredUsers[userId] = password;
    
    // 회원가입 성공 (200 OK)
    return {
      'message': '회원가입이 성공적으로 완료되었습니다.',
    };

    /* 실제 API 연결 시 사용할 코드
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'userId': userId,
          'password': password,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData;
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        return {
          'code': 'BAD_REQUEST',
          'message': errorData['message'] ?? '필수 입력 항목이 누락되었습니다.',
        };
      } else if (response.statusCode == 409) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        return {
          'code': 'CONFLICT',
          'message': errorData['message'] ?? '이미 사용 중인 아이디입니다.',
        };
      } else {
        return {
          'code': 'UNKNOWN_ERROR',
          'message': '회원가입에 실패했습니다.',
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

  // 카카오 로그인 API (테스트용 - 실제 API 연결 전까지)
  static Future<Map<String, dynamic>> kakaoLogin({
    required String code,
  }) async {
    // 실제 API 연결 전까지 테스트용 데이터 사용
    await Future.delayed(Duration(milliseconds: 500)); // 로딩 시뮬레이션
    
    // 테스트용 카카오 인증 코드 검증
    if (code.isEmpty || code == 'invalid_code') {
      // 400 Bad Request - 유효하지 않은 인가 코드
      return {
        'code': 'BAD_REQUEST',
        'message': '유효하지 않은 인가 코드입니다.',
      };
    }
    
    // 200 OK - 카카오 로그인 성공
    return {
      'message': '카카오 로그인이 성공적으로 완료되었습니다.',
      'accessToken': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.kakao_access_token_${DateTime.now().millisecondsSinceEpoch}',
      'refreshToken': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.kakao_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      'tokenType': 'Bearer',
      'expiresIn': 3600,
      'userId': 'kakao_user_${DateTime.now().millisecondsSinceEpoch}',
      'name': '카카오사용자',
    };

    /* 실제 API 연결 시 사용할 코드
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/kakao'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'code': code,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData;
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        return {
          'code': 'BAD_REQUEST',
          'message': errorData['message'] ?? '유효하지 않은 인가 코드입니다.',
        };
      } else {
        return {
          'code': 'UNKNOWN_ERROR',
          'message': '카카오 로그인에 실패했습니다.',
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

  // 버스 신청 API (테스트용 - 실제 API 연결 전까지)
  static Future<Map<String, dynamic>> createBusApplication({
    required String regionId,
    required String name,
    required int age,
    required String phoneNumber,
    required String address,
    required String selectedProgram,
    required String desiredBook,
  }) async {
    // 실제 API 연결 전까지 테스트용 데이터 사용
    await Future.delayed(Duration(milliseconds: 500)); // 로딩 시뮬레이션
    
    // 입력값 검증
    if (name.trim().isEmpty) {
      return {
        'code': 'BAD_REQUEST',
        'message': '이름을 입력해주세요.',
      };
    }
    
    if (age < 1 || age > 120) {
      return {
        'code': 'BAD_REQUEST',
        'message': '올바른 나이를 입력해주세요.',
      };
    }
    
    if (phoneNumber.trim().isEmpty) {
      return {
        'code': 'BAD_REQUEST',
        'message': '전화번호를 입력해주세요.',
      };
    }
    
    if (address.trim().isEmpty) {
      return {
        'code': 'BAD_REQUEST',
        'message': '주소를 입력해주세요.',
      };
    }
    
    // 프로그램과 희망도서는 선택사항이므로 검증하지 않음
    
    // 신청 완료 시 데이터 업데이트
    updateApplicationCount(regionId);
    
    // 성공 응답
    return {
      'message': '버스 신청이 완료되었습니다.',
    };

    /* 실제 API 연결 시 사용할 코드
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/applications'),
        headers: {
          'Content-Type': 'application/json',
          // 인증이 필요하다면 여기에 토큰 추가
          // 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'regionId': regionId,
          'name': name,
          'age': age,
          'phoneNumber': phoneNumber,
          'address': address,
          'selectedProgram': selectedProgram,
          'desiredBook': desiredBook,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData;
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        return {
          'code': 'BAD_REQUEST',
          'message': errorData['message'] ?? '잘못된 요청입니다.',
        };
      } else if (response.statusCode == 409) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        return {
          'code': 'CONFLICT',
          'message': errorData['message'] ?? '이미 신청한 사용자입니다.',
        };
      } else {
        return {
          'code': 'INTERNAL_ERROR',
          'message': '서버 오류가 발생했습니다.',
        };
      }
    } catch (e) {
      return {
        'code': 'NETWORK_ERROR',
        'message': '네트워크 오류가 발생했습니다: $e',
      };
    }
    */
  }

  // 신청 완료 시 데이터 업데이트 (테스트용)
  static void updateApplicationCount(String regionId) {
    if (_testData.containsKey(regionId)) {
      final currentData = _testData[regionId]!;
      final currentApplied = currentData['appliedCount'] as int;
      final currentRemaining = currentData['remaining'] as int;
      final currentCapacity = currentData['capacity'] as int;
      
      // 1명 증가
      final newApplied = currentApplied + 1;
      final newRemaining = currentRemaining - 1;
      
      // 퍼센트 계산 (100% 기준 50명)
      final newFillRate = (newApplied / 50.0) * 100.0;
      
      _testData[regionId] = {
        ...currentData,
        'appliedCount': newApplied,
        'remaining': newRemaining,
        'fillRatePercent': newFillRate,
      };
    }
  }
}
