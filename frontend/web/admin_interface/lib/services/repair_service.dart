import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/repair.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';

class RepairService {
  static final RepairService _instance = RepairService._internal();
  
  factory RepairService() {
    return _instance;
  }
  
  RepairService._internal();
  
  final AuthService _authService = AuthService();
  final String _baseUrl = ApiConfig.baseUrl;
  
  // Get all repairs with optional filtering and pagination
  Future<Map<String, dynamic>> getRepairs({
    int page = 1,
    int perPage = 10,
    String? search,
    int? vehicleId,
    int? customerId,
    String? status,
    String? sortBy,
    bool sortAsc = true,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final queryParams = {
      'page': page.toString(),
      'per_page': perPage.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (vehicleId != null) 'vehicle_id': vehicleId.toString(),
      if (customerId != null) 'customer_id': customerId.toString(),
      if (status != null) 'status': status,
      if (sortBy != null) 'sort_by': sortBy,
      'sort_direction': sortAsc ? 'asc' : 'desc',
      if (startDate != null) 'start_date': startDate.toIso8601String().split('T')[0],
      if (endDate != null) 'end_date': endDate.toIso8601String().split('T')[0],
    };

    final uri = Uri.parse('$_baseUrl/repairs').replace(queryParameters: queryParams);
    
    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> repairsJson = data['data'];
        final List<Repair> repairs = repairsJson
            .map((json) => Repair.fromJson(json))
            .toList();

        return {
          'repairs': repairs,
          'total': data['meta']['total'],
          'page': data['meta']['current_page'],
          'per_page': data['meta']['per_page'],
          'total_pages': data['meta']['last_page'],
        };
      } else {
        throw Exception('Failed to load repairs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load repairs: $e');
    }
  }
  
  // Get a single repair by ID
  Future<Repair> getRepair(int id) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('$_baseUrl/repairs/$id');
    
    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Repair.fromJson(data['data']);
      } else {
        throw Exception('Failed to load repair: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load repair: $e');
    }
  }
  
  // Create a new repair
  Future<Repair> createRepair(Map<String, dynamic> data) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('$_baseUrl/repairs');
    
    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return Repair.fromJson(responseData['data']);
      } else {
        throw Exception('Failed to create repair: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create repair: $e');
    }
  }
  
  // Update an existing repair
  Future<Repair> updateRepair(int id, Map<String, dynamic> data) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('$_baseUrl/repairs/$id');
    
    try {
      final response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Repair.fromJson(responseData['data']);
      } else {
        throw Exception('Failed to update repair: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update repair: $e');
    }
  }
  
  // Update just the status of a repair
  Future<Repair> updateStatus(int id, String status) async {
    return updateRepair(id, {'status': status});
  }
  
  // Delete a repair
  Future<void> deleteRepair(int id) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('$_baseUrl/repairs/$id');
    
    try {
      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete repair: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete repair: $e');
    }
  }
  
  // Get repair statistics
  Future<Map<String, dynamic>> getRepairStatistics() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('$_baseUrl/repairs/statistics');
    
    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      } else {
        throw Exception('Failed to load repair statistics: ${response.statusCode}');
      }
    } catch (e) {
      // For demo/development purposes, return mock data if the API is not available
      return _getMockStatistics();
    }
  }

  // Mock data for development/testing
  Map<String, dynamic> _getMockStatistics() {
    return {
      'total_repairs': 157,
      'completed_repairs': 98,
      'pending_repairs': 32,
      'in_progress_repairs': 27,
      'total_revenue': 47890.50,
      'status_distribution': {
        'pending': 32,
        'in_progress': 27,
        'completed': 98,
        'cancelled': 0,
      },
      'recent_repairs': [
        {
          'id': 1,
          'description': 'Oil change and filter replacement',
          'date': '2023-05-15',
          'status': 'completed',
          'cost': 120.00,
          'vehicle': 'BMW X5',
        },
        {
          'id': 2,
          'description': 'Brake pad replacement',
          'date': '2023-05-14',
          'status': 'completed',
          'cost': 350.00,
          'vehicle': 'Mercedes C200',
        },
        {
          'id': 3,
          'description': 'AC system repair',
          'date': '2023-05-13',
          'status': 'in_progress',
          'cost': 520.00,
          'vehicle': 'VW Golf',
        },
        {
          'id': 4,
          'description': 'Timing belt replacement',
          'date': '2023-05-12',
          'status': 'pending',
          'cost': 680.00,
          'vehicle': 'Audi A4',
        },
        {
          'id': 5,
          'description': 'Suspension system check',
          'date': '2023-05-11',
          'status': 'pending',
          'cost': 150.00,
          'vehicle': 'BMW 320i',
        },
      ],
      'vehicle_types': {
        'BMW': 45,
        'Mercedes': 38,
        'Audi': 29,
        'Volkswagen': 25,
        'Other': 20,
      },
    };
  }
} 