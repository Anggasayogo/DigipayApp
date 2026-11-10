import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_endpoints.dart';

class SessionStorage {
  static const String _keyToken = 'digipay_token';
  static const String _keyUser = 'digipay_user';
  static const String _keyBaseUrl = 'digipay_base_url';
  static const String _keyFavoriteBeneficiaries = 'digipay_favorites';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late SharedPreferences _prefs;

  static SessionStorage? _instance;
  static SessionStorage get instance {
    _instance ??= SessionStorage._internal();
    return _instance!;
  }

  SessionStorage._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token Management
  Future<void> saveToken(String token) async {
    await _prefs.setString(_keyToken, token);
    try {
      await _secureStorage.write(key: _keyToken, value: token);
    } catch (_) {}
  }

  Future<String?> getToken() async {
    final cached = _prefs.getString(_keyToken);
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }
    try {
      final secure = await _secureStorage.read(key: _keyToken);
      if (secure != null && secure.isNotEmpty) {
        await _prefs.setString(_keyToken, secure);
        return secure;
      }
    } catch (_) {}
    return null;
  }

  Future<void> clearToken() async {
    await _prefs.remove(_keyToken);
    try {
      await _secureStorage.delete(key: _keyToken);
    } catch (_) {}
  }

  // User Profile Data
  Future<void> saveUser(Map<String, dynamic> userData) async {
    await _prefs.setString(_keyUser, jsonEncode(userData));
  }

  Map<String, dynamic>? getUser() {
    final raw = _prefs.getString(_keyUser);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearUser() async {
    await _prefs.remove(_keyUser);
  }

  // Base URL Configuration
  String getBaseUrl() {
    final saved = _prefs.getString(_keyBaseUrl);
    if (saved != null && saved.isNotEmpty) {
      return saved;
    }
    // Default to Production API URL
    return ApiEndpoints.prodBaseUrl;
  }

  Future<void> saveBaseUrl(String url) async {
    await _prefs.setString(_keyBaseUrl, url.trim());
  }

  // Favorite Beneficiary IDs
  List<String> getFavoriteBeneficiaryIds() {
    return _prefs.getStringList(_keyFavoriteBeneficiaries) ?? [];
  }

  Future<void> toggleFavoriteBeneficiary(String beneficiaryId) async {
    final list = getFavoriteBeneficiaryIds().toList();
    if (list.contains(beneficiaryId)) {
      list.remove(beneficiaryId);
    } else {
      list.add(beneficiaryId);
    }
    await _prefs.setStringList(_keyFavoriteBeneficiaries, list);
  }

  bool isFavoriteBeneficiary(String beneficiaryId) {
    return getFavoriteBeneficiaryIds().contains(beneficiaryId);
  }

  // Full Logout
  Future<void> clearSession() async {
    await clearToken();
    await clearUser();
  }
}
