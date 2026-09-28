import 'package:dio/dio.dart';
import 'package:ntodo/core/network/api_urls.dart';
import 'package:ntodo/features/auth/data/model/login_model.dart';
import 'package:ntodo/features/auth/data/model/register_model.dart';

import '../../../../../core/network/dio_clinet.dart';
import '../../../../../core/untils/logger.dart';
import '../local/auth_local_remote_datasource.dart';
import 'user_remote_datasource.dart';

class UserRemoteDatasourceImpl implements UserRemoteDatasource {
  final DioClinet dioClient;
  final AuthLocalRemoteDatasource local;

  const UserRemoteDatasourceImpl({
    required this.local,
    required this.dioClient,
  });

  @override
  Future<RegisterModel> register({
    required String password,
    required String username,
  }) async {
    try {
      final response = await dioClient.post(
        ApiUrls.register,
        data: {"password": password, "username": username},
      );

      final data = response.data;
      LoggerService.info('Register successful: $username');

      if (data is Map) {
        return RegisterModel.fromJson(data.cast<String, dynamic>());
      }
      return RegisterModel(message: data?.toString());
    } on DioException catch (e, s) {
      LoggerService.error('Register failed: ${e.response?.data ?? e.message}', e, s);
      rethrow;
    } catch (e, s) {
      LoggerService.error('Register: unexpected error', e, s);
      rethrow;
    }
  }

  @override
  Future<LoginModel> login({
    required String password,
    required String username,
  }) async {
    try {
      final response = await dioClient.post(
        ApiUrls.login,
        data: {"password": password, "username": username},
      );

      final data = response.data;
      if (data is! Map || data['token'] is! String) {
        throw FormatException('Login response has no token: $data');
      }

      final model = LoginModel.fromJson(data.cast<String, dynamic>());
      await local.saveAccessToken(model.token);
      await local.saveUsername(username);
      LoggerService.info('Login successful: $username');
      return model;
    } on DioException catch (e, s) {
      LoggerService.error('Login failed: ${e.response?.data ?? e.message}', e, s);
      rethrow;
    } catch (e, s) {
      LoggerService.error('Login: unexpected error', e, s);
      rethrow;
    }
  }

  /// Signing out must always succeed locally, even if the server call fails
  /// (expired token, no network) — otherwise the user is stuck logged in.
  @override
  Future<void> logout() async {
    try {
      await dioClient.post(ApiUrls.logout);
      LoggerService.info('Logout successful');
    } on DioException catch (e, s) {
      LoggerService.warning('Server logout failed, clearing local session anyway');
      LoggerService.error('Logout: ${e.response?.data ?? e.message}', e, s);
    } catch (e, s) {
      LoggerService.error('Logout: unexpected error', e, s);
    } finally {
      await local.logout();
    }
  }
}
