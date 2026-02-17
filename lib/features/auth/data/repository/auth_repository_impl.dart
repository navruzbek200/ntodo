import 'package:ntodo/features/auth/data/datasource/remote/user_remote_datasource.dart';
import 'package:ntodo/features/auth/domain/entities/login_entity.dart';
import 'package:ntodo/features/auth/domain/entities/register_entity.dart';
import '../../domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final UserRemoteDatasource userRemoteDatasource;

  AuthRepositoryImpl({required this.userRemoteDatasource});

  @override
  Future<RegisterEntity> register({
    required String password,
    required String username,
  }) {
    return userRemoteDatasource.register(
      password: password,
      username: username,
    );
  }

  @override
  Future<LoginEntity> login({
    required String password,
    required String username,
  }) {
    return userRemoteDatasource.login(password: password, username: username);
  }

  @override
  Future<void> logout() {
    return userRemoteDatasource.logout();
  }
}
