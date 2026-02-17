import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  final SharedPreferences prefs;
  LocalStorage(this.prefs);

  Future<void> writeString(String key, String value) async {
    await prefs.setString(key, value);
  }

  String? readString(String key) {
    return prefs.getString(key);
  }

  Future<void> delete(String key) async {
    await prefs.remove(key);
  }
}
