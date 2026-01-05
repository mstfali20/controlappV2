import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  Prefs(this._prefs);

  final SharedPreferences _prefs;

  static Future<Prefs> create() async {
    final prefs = await SharedPreferences.getInstance();
    return Prefs(prefs);
  }

  String? getString(String key) => _prefs.getString(key);

  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  bool? getBool(String key) => _prefs.getBool(key);

  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  int? getInt(String key) => _prefs.getInt(key);

  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  Future<bool> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);

  Future<bool> remove(String key) => _prefs.remove(key);

  Future<void> setStrings(Map<String, String> items) async {
    for (final entry in items.entries) {
      await _prefs.setString(entry.key, entry.value);
    }
  }

  Future<void> clearKeys(Iterable<String> keys) async {
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}
