  import 'package:hive/hive.dart';
  import '../../../../../core/constants/storage_keys.dart';
  import '../../../../../core/storage/local_storage.dart';
  import 'auth_local_remote_datasource.dart';

  class AuthLocalDataSourceImpl implements AuthLocalRemoteDatasource {
    final LocalStorage storage;
    final Box box;

    AuthLocalDataSourceImpl(this.storage, this.box);

    @override
    Future<void> saveRememberMe(String username, String password) async {
      await box.put('username', username);
      await box.put('password', password);

    }

    @override
    String? getUsername() {
      final raw = storage.readString(StorageKeys.username);
      if (raw == null || raw.trim().isEmpty) return null;
      return raw.trim();
    }

    @override
    String? getPassword() {
      final raw = storage.readString(StorageKeys.password);
      if (raw == null || raw.isEmpty) return null;
      return raw;
    }

    @override
    Future<void> saveCredentials({
      required String username,
      required String password,
    }) async {
      await storage.writeString(StorageKeys.username, username.trim());
      await storage.writeString(StorageKeys.password, password);
    }

    @override
    Future<void> saveUsername(String username) async {
      await storage.writeString(StorageKeys.username, username.trim());
    }

    @override
    Future<void> logout() async {
      await storage.delete(StorageKeys.username);
      await storage.delete(StorageKeys.password);
      await storage.delete(StorageKeys.token);
    }

    @override
    String? getAccessToken() {
      final raw = storage.readString(StorageKeys.token);
      if (raw == null || raw.trim().isEmpty) return null;
      return raw.trim();
    }

    @override
    Future<void> saveAccessToken(String token) async {
      await storage.writeString(StorageKeys.token, token.trim());
    }

    @override
    bool isLoggedIn() {
      final token = getAccessToken();
      return token != null && token.isNotEmpty;
    }


  }
