import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  
  factory AuthService() {
    return _instance;
  }
  
  AuthService._internal();
  
  final _secureStorage = const FlutterSecureStorage();
  
  // Base URL for the API
  final String _baseUrl = 'https://api.ecar.tn/api/v1';
  
  // Key for storing the auth token
  static const String _tokenKey = 'admin_auth_token';
  
  // Key for storing the user profile
  static const String _userProfileKey = 'admin_user_profile';
  
  /// Login with email and password
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Save the auth token
        await _secureStorage.write(
          key: _tokenKey,
          value: data['token'],
        );
        
        // Save the user profile
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          _userProfileKey,
          jsonEncode(data['user']),
        );
        
        return true;
      } else {
        // Handle different error codes
        switch (response.statusCode) {
          case 401:
            throw Exception('Invalid credentials');
          case 403:
            throw Exception('Not authorized as admin');
          default:
            throw Exception('Login failed: ${response.body}');
        }
      }
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }
  
  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      return token != null;
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return false;
    }
  }
  
  /// Get the current auth token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }
  
  /// Get the current user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userProfileKey);
      
      if (userJson != null) {
        return jsonDecode(userJson) as Map<String, dynamic>;
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }
  
  /// Logout the user
  Future<void> logout() async {
    try {
      // Clear the auth token
      await _secureStorage.delete(key: _tokenKey);
      
      // Clear the user profile
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userProfileKey);
    } catch (e) {
      debugPrint('Error during logout: $e');
      rethrow;
    }
  }
  
  /// Refresh the token if needed
  Future<String?> refreshToken() async {
    try {
      final token = await getToken();
      
      if (token == null) {
        return null;
      }
      
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/refresh_token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newToken = data['token'];
        
        // Save the new token
        await _secureStorage.write(
          key: _tokenKey,
          value: newToken,
        );
        
        return newToken;
      } else {
        // Token refresh failed, user needs to login again
        await logout();
        return null;
      }
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      return null;
    }
  }
} 