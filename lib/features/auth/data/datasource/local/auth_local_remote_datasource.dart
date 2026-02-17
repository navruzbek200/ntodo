abstract class AuthLocalRemoteDatasource {

  // Remember me (Hive)
  Future<void> saveRememberMe(String username, String password);

  // Credentials (LocalStorage)
  Future<void> saveCredentials({
    required String username,
    required String password,
  });

  Future<void> saveUsername(String username);

  // Token
  Future<void> saveAccessToken(String token);
  String? getAccessToken();

  // Login status check
  bool isLoggedIn();

  // Logout
  Future<void> logout();

  // Getters
  String? getUsername();
  String? getPassword();
}