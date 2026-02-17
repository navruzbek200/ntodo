import 'package:ntodo/features/auth/data/model/login_model.dart';
import 'package:ntodo/features/auth/data/model/register_model.dart';

abstract class UserRemoteDatasource {
  Future<RegisterModel> register({
    required String password,
    required String username,
  });

  Future<LoginModel> login({
    required String password,
    required String username,
  });

  Future<void> logout();
}
