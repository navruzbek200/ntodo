import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the user's light/dark choice (defaults to the system setting)
/// and remembers it across launches.
class ThemeController extends ValueNotifier<ThemeMode> {
  static const _key = 'theme_mode';
  final SharedPreferences _prefs;

  ThemeController(this._prefs) : super(_read(_prefs));

  static ThemeMode _read(SharedPreferences prefs) {
    return switch (prefs.getString(_key)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  /// Flips between light and dark based on what is on screen right now.
  void toggle(Brightness current) {
    value = current == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    _prefs.setString(_key, value.name);
  }
}
