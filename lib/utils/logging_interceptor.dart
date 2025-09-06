import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🚀 REQUEST[${options.method}] => PATH: ${options.path}');
    print('📤 Headers: ${options.headers}');
    print('📤 Data: ${options.data}');
    print('📤 Query Parameters: ${options.queryParameters}');
    print('---');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    print('📥 Data: ${response.data}');
    print('📥 Headers: ${response.headers}');
    print('---');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    print('📥 Error Message: ${err.message}');
    print('📥 Error Data: ${err.response?.data}');
    print('📥 Error Headers: ${err.response?.headers}');
    print('---');
    super.onError(err, handler);
  }
}
