import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/repair.dart';
import 'auth_service.dart';

class RepairService {
  final String baseUrl = 'http://localhost:3000/api/v1';
  final AuthService _authService = AuthService();
  
  Future<List<Repair>> getRepairs() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }
    
    final response = await http.get(
      Uri.parse('$baseUrl/repairs'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Repair.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load repairs');
    }
  }
  
  Future<List<Repair>> getRepairsForVehicle(int vehicleId) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }
    
    final response = await http.get(
      Uri.parse('$baseUrl/vehicles/$vehicleId/repairs'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Repair.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load repairs for vehicle');
    }
  }
  
  Future<Repair> getRepair(int id) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }
    
    final response = await http.get(
      Uri.parse('$baseUrl/repairs/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Repair.fromJson(data);
    } else {
      throw Exception('Failed to load repair details');
    }
  }
} 