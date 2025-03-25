import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/vehicle.dart';
import 'auth_service.dart';

class VehicleService {
  static final VehicleService _instance = VehicleService._internal();
  
  factory VehicleService() {
    return _instance;
  }
  
  VehicleService._internal();
  
  final AuthService _authService = AuthService();
  final String _baseUrl = 'https://api.ecar.tn/api/v1';
  
  // Get all vehicles with pagination and optional filtering
  Future<Map<String, dynamic>> getVehicles({
    int page = 1,
    int perPage = 10,
    String? search,
    int? customerId,
    String? brand,
    String? sortBy,
    bool sortAsc = true,
  }) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        if (customerId != null) 'customer_id': customerId.toString(),
        if (brand != null && brand.isNotEmpty) 'brand': brand,
        if (sortBy != null && sortBy.isNotEmpty) 'sort_by': sortBy,
        'sort_asc': sortAsc.toString(),
      };
      
      final uri = Uri.parse('$_baseUrl/admin/vehicles').replace(
        queryParameters: queryParams,
      );
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        final vehicles = (data['vehicles'] as List)
            .map((json) => Vehicle.fromJson(json))
            .toList();
        
        return {
          'vehicles': vehicles,
          'total': data['total'],
          'page': data['page'],
          'per_page': data['per_page'],
          'total_pages': data['total_pages'],
        };
      } else if (response.statusCode == 401) {
        // Try to refresh token and retry
        final newToken = await _authService.refreshToken();
        
        if (newToken != null) {
          return getVehicles(
            page: page,
            perPage: perPage,
            search: search,
            customerId: customerId,
            brand: brand,
            sortBy: sortBy,
            sortAsc: sortAsc,
          );
        } else {
          throw Exception('Authentication expired');
        }
      } else {
        throw Exception('Failed to load vehicles: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error getting vehicles: $e');
      rethrow;
    }
  }
  
  // Get a single vehicle by ID
  Future<Vehicle> getVehicle(int id) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/vehicles/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Vehicle.fromJson(data);
      } else if (response.statusCode == 401) {
        // Try to refresh token and retry
        final newToken = await _authService.refreshToken();
        
        if (newToken != null) {
          return getVehicle(id);
        } else {
          throw Exception('Authentication expired');
        }
      } else {
        throw Exception('Failed to load vehicle: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error getting vehicle: $e');
      rethrow;
    }
  }
  
  // Create a new vehicle
  Future<Vehicle> createVehicle(Map<String, dynamic> vehicleData) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/vehicles'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(vehicleData),
      );
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Vehicle.fromJson(data);
      } else if (response.statusCode == 401) {
        // Try to refresh token and retry
        final newToken = await _authService.refreshToken();
        
        if (newToken != null) {
          return createVehicle(vehicleData);
        } else {
          throw Exception('Authentication expired');
        }
      } else {
        throw Exception('Failed to create vehicle: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error creating vehicle: $e');
      rethrow;
    }
  }
  
  // Update an existing vehicle
  Future<Vehicle> updateVehicle(int id, Map<String, dynamic> vehicleData) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await http.put(
        Uri.parse('$_baseUrl/admin/vehicles/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(vehicleData),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Vehicle.fromJson(data);
      } else if (response.statusCode == 401) {
        // Try to refresh token and retry
        final newToken = await _authService.refreshToken();
        
        if (newToken != null) {
          return updateVehicle(id, vehicleData);
        } else {
          throw Exception('Authentication expired');
        }
      } else {
        throw Exception('Failed to update vehicle: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error updating vehicle: $e');
      rethrow;
    }
  }
  
  // Update vehicle mileage
  Future<Vehicle> updateMileage(int id, int mileage) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await http.patch(
        Uri.parse('$_baseUrl/admin/vehicles/$id/update_mileage'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'current_mileage': mileage}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Vehicle.fromJson(data);
      } else if (response.statusCode == 401) {
        // Try to refresh token and retry
        final newToken = await _authService.refreshToken();
        
        if (newToken != null) {
          return updateMileage(id, mileage);
        } else {
          throw Exception('Authentication expired');
        }
      } else {
        throw Exception('Failed to update mileage: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error updating mileage: $e');
      rethrow;
    }
  }
  
  // Delete a vehicle
  Future<bool> deleteVehicle(int id) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await http.delete(
        Uri.parse('$_baseUrl/admin/vehicles/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        // Try to refresh token and retry
        final newToken = await _authService.refreshToken();
        
        if (newToken != null) {
          return deleteVehicle(id);
        } else {
          throw Exception('Authentication expired');
        }
      } else {
        throw Exception('Failed to delete vehicle: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error deleting vehicle: $e');
      rethrow;
    }
  }
  
  // Get available brands and models for dropdown selection
  Future<Map<String, List<String>>> getVehicleOptions() async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/vehicle_options'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // If the API is not yet implemented, return hardcoded values
        if (response.statusCode != 200) {
          return {
            'BMW': ['3 Series', '5 Series', 'X3', 'X5'],
            'Mercedes-Benz': ['C-Class', 'E-Class', 'GLC', 'GLE'],
            'Volkswagen': ['Golf', 'Passat', 'Tiguan', 'Polo'],
            'Audi': ['A3', 'A4', 'Q3', 'Q5'],
            'Renault': ['Clio', 'Symbol', 'Mégane', 'Duster'],
            'Peugeot': ['208', '301', '3008', '508'],
            'Citroën': ['C3', 'C4', 'C-Elysée'],
            'Hyundai': ['i10', 'i20', 'Accent', 'Tucson'],
            'Kia': ['Picanto', 'Rio', 'Sportage'],
            'Toyota': ['Yaris', 'Corolla', 'RAV4'],
            'SEAT': ['Ibiza', 'Leon', 'Ateca'],
            'Fiat': ['Tipo', '500'],
          };
        }
        
        // Convert API response to Map<String, List<String>>
        final Map<String, List<String>> options = {};
        final Map<String, dynamic> brandsModels = data['brands_models'];
        
        brandsModels.forEach((brand, models) {
          options[brand] = List<String>.from(models);
        });
        
        return options;
      } else if (response.statusCode == 401) {
        // Try to refresh token and retry
        final newToken = await _authService.refreshToken();
        
        if (newToken != null) {
          return getVehicleOptions();
        } else {
          throw Exception('Authentication expired');
        }
      } else {
        // Return hardcoded values for development
        return {
          'BMW': ['3 Series', '5 Series', 'X3', 'X5'],
          'Mercedes-Benz': ['C-Class', 'E-Class', 'GLC', 'GLE'],
          'Volkswagen': ['Golf', 'Passat', 'Tiguan', 'Polo'],
          'Audi': ['A3', 'A4', 'Q3', 'Q5'],
          'Renault': ['Clio', 'Symbol', 'Mégane', 'Duster'],
          'Peugeot': ['208', '301', '3008', '508'],
          'Citroën': ['C3', 'C4', 'C-Elysée'],
          'Hyundai': ['i10', 'i20', 'Accent', 'Tucson'],
          'Kia': ['Picanto', 'Rio', 'Sportage'],
          'Toyota': ['Yaris', 'Corolla', 'RAV4'],
          'SEAT': ['Ibiza', 'Leon', 'Ateca'],
          'Fiat': ['Tipo', '500'],
        };
      }
    } catch (e) {
      debugPrint('Error getting vehicle options: $e');
      // Return hardcoded values on error
      return {
        'BMW': ['3 Series', '5 Series', 'X3', 'X5'],
        'Mercedes-Benz': ['C-Class', 'E-Class', 'GLC', 'GLE'],
        'Volkswagen': ['Golf', 'Passat', 'Tiguan', 'Polo'],
        'Audi': ['A3', 'A4', 'Q3', 'Q5'],
        'Renault': ['Clio', 'Symbol', 'Mégane', 'Duster'],
        'Peugeot': ['208', '301', '3008', '508'],
        'Citroën': ['C3', 'C4', 'C-Elysée'],
        'Hyundai': ['i10', 'i20', 'Accent', 'Tucson'],
        'Kia': ['Picanto', 'Rio', 'Sportage'],
        'Toyota': ['Yaris', 'Corolla', 'RAV4'],
        'SEAT': ['Ibiza', 'Leon', 'Ateca'],
        'Fiat': ['Tipo', '500'],
      };
    }
  }
} 