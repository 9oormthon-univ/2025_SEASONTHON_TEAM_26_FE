import 'package:dio/dio.dart';
import '../utils/logging_interceptor.dart';
import '../utils/token_manager.dart';

class DioService {
  static Dio? _dio;
  
  static Dio get dio {
    if (_dio == null) {
      _dio = Dio();
      
      // 기본 설정
      _dio!.options.baseUrl = 'https://two025-seasonthon-team-26-be.onrender.com/api';
      _dio!.options.connectTimeout = const Duration(seconds: 30);
      _dio!.options.receiveTimeout = const Duration(seconds: 30);
      _dio!.options.sendTimeout = const Duration(seconds: 30);
      
      // 200-299 상태 코드를 성공으로 처리 (200, 201, 202 등)
      _dio!.options.validateStatus = (status) {
        return status != null && status >= 200 && status < 300;
      };
      
      // 로깅 인터셉터 추가
      _dio!.interceptors.add(LoggingInterceptor());
      
      // 인증 인터셉터 추가
      _dio!.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 액세스 토큰이 있으면 헤더에 추가
          final accessToken = await AppTokenManager.getAccessToken();
          print("🔐 인증 인터셉터 실행됨 - accessToken: ${accessToken != null ? "있음 (${accessToken.substring(0, 20)}...)" : "없음"}");
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // 401 에러 시 토큰 재발급 시도
          if (error.response?.statusCode == 401) {
            try {
              final refreshToken = await AppTokenManager.getRefreshToken();
              if (refreshToken != null) {
                // 토큰 재발급 API 호출
                final response = await Dio().post(
                  '${_dio!.options.baseUrl}/auth/token/refresh',
                  data: {'refreshToken': refreshToken},
                );
                
                if (response.statusCode == 200) {
                  final newAccessToken = response.data['accessToken'];
                  final newRefreshToken = response.data['refreshToken'];
                  
                  // 새 토큰 저장
                  await AppTokenManager.saveTokens(
                    accessToken: newAccessToken,
                    refreshToken: newRefreshToken,
                    expiresIn: response.data['expiresIn'] ?? 3600,
                    userId: await AppTokenManager.getUserId(),
                    userName: await AppTokenManager.getUserName(),
                  );
                  
                  // 원래 요청에 새 토큰으로 재시도
                  error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                  final retryResponse = await _dio!.fetch(error.requestOptions);
                  handler.resolve(retryResponse);
                  return;
                }
              }
            } catch (e) {
              // 토큰 재발급 실패 시 로그아웃 처리
              await AppTokenManager.clearTokens();
            }
          }
          handler.next(error);
        },
      ));
      
      // 기본 헤더 설정
      _dio!.options.headers = {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      };
    }
    return _dio!;
  }
  
  // GET 요청
  static Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return dio.get(path, queryParameters: queryParameters);
  }
  
  // POST 요청
  static Future<Response> post(String path, {dynamic data}) {
    return dio.post(path, data: data);
  }
  
  // PUT 요청
  static Future<Response> put(String path, {dynamic data}) {
    return dio.put(path, data: data);
  }
  
  // DELETE 요청
  static Future<Response> delete(String path) {
    return dio.delete(path);
  }
}
