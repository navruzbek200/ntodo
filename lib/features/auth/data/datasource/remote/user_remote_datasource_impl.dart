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

      final status = response.statusCode ?? 0;

      if (status == 200 || status == 201) {
        LoggerService.info('customer register successful: ${response.data}');

        final data = response.data;

        if (data is Map<String, dynamic>) {
          return RegisterModel.fromJson(data);
        }

        if (data is Map) {
          return RegisterModel.fromJson(data.cast<String, dynamic>());
        }

        return RegisterModel(message: data?.toString());
      }

      LoggerService.warning("customer register failed: $status");
      throw Exception('customer register failed: $status');
    } on DioError catch (e, s) {
      LoggerService.error('Dio error during customer register: ${e.message}');
      LoggerService.error('Response: ${e.response?.data}');
      LoggerService.error('Stack: $s');
      rethrow;
    } catch (e, s) {
      LoggerService.error('Error during customer register: $e');
      LoggerService.error('Stack: $s');
      rethrow;
    }
  }

  @override
  Future<LoginModel> login(
      {required String password, required String username}) async {
    try {
      final response = await dioClient.post(
        ApiUrls.login,
        data: {"password": password, "username": username},
      );

      final status = response.statusCode ?? 0;

      if (status == 200 || status == 201) {
        LoggerService.info('customer register successful: ${response.data}');

        final data = response.data;

        if (data is Map<String, dynamic>) {
          return LoginModel.fromJson(data);
        }

        if (data is Map) {
          return LoginModel.fromJson(data.cast<String, dynamic>());
        }

        return LoginModel(token: data!.toString());
      }

      LoggerService.warning("customer register failed: $status");
      throw Exception('customer register failed: $status');
    } on DioError catch (e, s) {
      LoggerService.error('Dio error during customer register: ${e.message}');
      LoggerService.error('Response: ${e.response?.data}');
      LoggerService.error('Stack: $s');
      rethrow;
    } catch (e, s) {
      LoggerService.error('Error during customer register: $e');
      LoggerService.error('Stack: $s');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      final response = await dioClient.post(ApiUrls.logout);

      final status = response.statusCode ?? 0;

      if (status == 200 || status == 201) {
        LoggerService.info('logout successful: ${response.data}');
        await local.logout(); 
        return;
      }

      LoggerService.warning("logout failed: $status");
      throw Exception('logout failed: $status');
    } on DioError catch (e, s) {
      LoggerService.error('Dio error during logout: ${e.message}');
      LoggerService.error('Response: ${e.response?.data}');
      LoggerService.error('Stack: $s');
      rethrow;
    } catch (e, s) {
      LoggerService.error('Error during logout: $e');
      LoggerService.error('Stack: $s');
      rethrow;
    }
  }
}