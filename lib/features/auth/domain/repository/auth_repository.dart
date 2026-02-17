import 'package:ntodo/features/auth/domain/entities/login_entity.dart';
import 'package:ntodo/features/auth/domain/entities/register_entity.dart';

abstract class AuthRepository {


  Future<RegisterEntity> register({
    required String password,
    required String username,
  });
  Future<LoginEntity> login({
    required String password,
    required String username,
  });
  Future<void> logout();
}
