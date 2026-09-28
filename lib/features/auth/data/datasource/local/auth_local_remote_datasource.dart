abstract class AuthLocalRemoteDatasource {
  Future<void> saveUsername(String username);
  String? getUsername();

  // Token
  Future<void> saveAccessToken(String token);
  String? getAccessToken();

  // Login status check
  bool isLoggedIn();

  // Logout: clears everything stored for the session
  Future<void> logout();
}
