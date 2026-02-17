import 'dart:async';
import 'package:dio/dio.dart';
import '../../features/auth/data/datasource/local/auth_local_remote_datasource.dart';
import 'api_urls.dart';

class DioClinet {
  final Dio _dio;
  final AuthLocalRemoteDatasource local;



  DioClinet({required this.local})
      : _dio = Dio(
    BaseOptions(
      baseUrl: ApiUrls.baseUrl,
      headers: {'Content-Type': 'application/json'},
    ),
  ) {
    _dio.interceptors.add(
      LogInterceptor(request: true, requestBody: true, responseBody: true, error: true),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final isAuthFree =
              options.path.contains('login') || options.path.contains('register');

          if (!isAuthFree) {
            final token = await local.getAccessToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },


      ),
    );
  }



  Future<Response> get(String path, {Map<String, dynamic>? queryParams, Options? options}) =>
      _dio.get(path, queryParameters: queryParams, options: options);

  Future<Response> post(String path, {dynamic data, Options? options}) =>
      _dio.post(path, data: data, options: options);

  Future<Response> put(String path, {dynamic data, Options? options}) =>
      _dio.put(path, data: data, options: options);

  Future<Response> patch(String path, {dynamic data, Options? options}) =>
      _dio.patch(path, data: data, options: options);

  Future<Response> delete(String path, {Map<String, dynamic>? queryParams, Options? options}) =>
      _dio.delete(path, queryParameters: queryParams, options: options);

}