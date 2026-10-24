import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  static final SecureStorageService instance = SecureStorageService._internal();
  factory SecureStorageService() => instance;
  SecureStorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
  );

  static const String _keyGeminiApiKey = 'jx_gemini_api_key_secure';
  static const String _keySelectedModel = 'jx_selected_gemini_model';
  static const String _keySelectedLanguage = 'jx_selected_language';

  Future<void> saveApiKey(String apiKey) async {
    if (apiKey.isEmpty) {
      await _secureStorage.delete(key: _keyGeminiApiKey);
    } else {
      await _secureStorage.write(key: _keyGeminiApiKey, value: apiKey.trim());
    }
  }

  Future<String?> getApiKey() async {
    try {
      final secureKey = await _secureStorage.read(key: _keyGeminiApiKey);
      if (secureKey != null && secureKey.isNotEmpty) {
        return secureKey;
      }
      // Fallback check in SharedPreferences for migration
      final prefs = await SharedPreferences.getInstance();
      final prefKey = prefs.getString('gemini_api_key');
      if (prefKey != null && prefKey.isNotEmpty) {
        await saveApiKey(prefKey);
        return prefKey;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSelectedModel(String model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedModel, model);
  }

  Future<String> getSelectedModel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedModel) ?? 'gemini-2.0-flash';
  }

  Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedLanguage, language);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedLanguage) ?? 'Auto';
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySelectedModel);
    await prefs.remove(_keySelectedLanguage);
    await prefs.remove('jx_first_run_completed');
    await prefs.remove('jx_app_lock_enabled');
  }
}
