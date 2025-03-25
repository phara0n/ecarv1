import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/customer.dart';

class AuthService {
  final String baseUrl = 'http://localhost:3000/api/v1';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      
      // Store the token securely
      await _storage.write(key: 'auth_token', value: token);
      
      return token;
    } else {
      // Handle login error
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to login');
    }
  }
  
  Future<void> logout() async {
    // Clear the stored token
    await _storage.delete(key: 'auth_token');
  }
  
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
  
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
  
  Future<Customer> getCurrentUser() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }
    
    // Get the current user's profile from the API
    final response = await http.get(
      Uri.parse('$baseUrl/customers/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Customer.fromJson(data);
    } else {
      throw Exception('Failed to get current user');
    }
  }
} 