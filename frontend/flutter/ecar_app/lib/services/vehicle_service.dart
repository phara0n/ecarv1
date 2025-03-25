import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle.dart';
import 'auth_service.dart';

class VehicleService {
  final String baseUrl = 'http://localhost:3000/api/v1';
  final AuthService _authService = AuthService();
  
  Future<List<Vehicle>> getVehicles() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }
    
    final response = await http.get(
      Uri.parse('$baseUrl/vehicles'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Vehicle.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load vehicles');
    }
  }
  
  Future<Vehicle> getVehicle(int id) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }
    
    final response = await http.get(
      Uri.parse('$baseUrl/vehicles/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Vehicle.fromJson(data);
    } else {
      throw Exception('Failed to load vehicle');
    }
  }
  
  Future<Vehicle> createVehicle(Vehicle vehicle) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }
    
    final response = await http.post(
      Uri.parse('$baseUrl/vehicles'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'vehicle': vehicle.toJson()}),
    );
    
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Vehicle.fromJson(data);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['errors'] ?? 'Failed to create vehicle');
    }
  }
  
  Future<Vehicle> updateMileage(int id, int mileage) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }
    
    final response = await http.patch(
      Uri.parse('$baseUrl/vehicles/$id/update_mileage'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'current_mileage': mileage}),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Vehicle.fromJson(data);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['errors'] ?? 'Failed to update mileage');
    }
  }
} 