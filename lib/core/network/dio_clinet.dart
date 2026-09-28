import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../features/auth/data/datasource/local/auth_local_remote_datasource.dart';
import '../untils/logger.dart';
import 'api_urls.dart';

class DioClinet {
  final Dio _dio;
  final AuthLocalRemoteDatasource local;

  /// Called once the server rejects our token (401 on a protected endpoint).
  final FutureOr<void> Function()? onUnauthorized;

  DioClinet({required this.local, this.onUnauthorized})
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiUrls.baseUrl,
          headers: {'Content-Type': 'application/json'},
          connectTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (!ApiUrls.authFree.contains(options.path)) {
            final token = local.getAccessToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (e, handler) async {
          final path = e.requestOptions.path;
          if (e.response?.statusCode == 401 &&
              !ApiUrls.authFree.contains(path) &&
              path != ApiUrls.logout) {
            LoggerService.warning('401 on $path → clearing session');
            await local.logout();
            await onUnauthorized?.call();
          }
          return handler.next(e);
        },
      ),
    );

    if (kDebugMode) _dio.interceptors.add(_ApiLogInterceptor());
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParams,
    Options? options,
  }) => _dio.get(path, queryParameters: queryParams, options: options);

  Future<Response> post(String path, {dynamic data, Options? options}) =>
      _dio.post(path, data: data, options: options);

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Options? options,
  }) => _dio.put(path, data: data, queryParameters: queryParams, options: options);

  Future<Response> patch(String path, {dynamic data, Options? options}) =>
      _dio.patch(path, data: data, options: options);

  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParams,
    Options? options,
  }) => _dio.delete(path, queryParameters: queryParams, options: options);
}

/// Compact request/response log; never prints the token or passwords.
class _ApiLogInterceptor extends Interceptor {
  static const _started = '_startedAt';

  @override
  void onRequest(RequestOptions o, RequestInterceptorHandler handler) {
    o.extra[_started] = DateTime.now();
    LoggerService.debug('→ ${o.method} ${o.uri}\nbody: ${_safe(o.data)}');
    handler.next(o);
  }

  @override
  void onResponse(Response r, ResponseInterceptorHandler handler) {
    LoggerService.info(
      '← ${r.statusCode} ${r.requestOptions.method} ${r.requestOptions.path} '
      '(${_elapsed(r.requestOptions)} ms)\n${r.data}',
    );
    handler.next(r);
  }

  @override
  void onError(DioException e, ErrorInterceptorHandler handler) {
    final o = e.requestOptions;
    LoggerService.error(
      '✗ ${e.response?.statusCode ?? e.type.name} ${o.method} ${o.path} '
      '(${_elapsed(o)} ms)\n${e.response?.data ?? e.message}',
    );
    handler.next(e);
  }

  int _elapsed(RequestOptions o) {
    final start = o.extra[_started];
    return start is DateTime ? DateTime.now().difference(start).inMilliseconds : -1;
  }

  Object? _safe(Object? data) {
    if (data is Map && data.containsKey('password')) {
      return {...data, 'password': '***'};
    }
    return data;
  }
}
