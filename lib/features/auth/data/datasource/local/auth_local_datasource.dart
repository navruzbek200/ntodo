import '../../../../../core/constants/storage_keys.dart';
import '../../../../../core/storage/local_storage.dart';
import 'auth_local_remote_datasource.dart';

class AuthLocalDataSourceImpl implements AuthLocalRemoteDatasource {
  final LocalStorage storage;

  AuthLocalDataSourceImpl(this.storage) {
    // Older builds stored the raw password; never keep it on the device.
    if (storage.readString(StorageKeys.legacyPassword) != null) {
      storage.delete(StorageKeys.legacyPassword);
    }
  }

  @override
  String? getUsername() {
    final raw = storage.readString(StorageKeys.username);
    if (raw == null || raw.trim().isEmpty) return null;
    return raw.trim();
  }

  @override
  Future<void> saveUsername(String username) async {
    await storage.writeString(StorageKeys.username, username.trim());
  }

  @override
  Future<void> logout() async {
    await storage.delete(StorageKeys.username);
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
