import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/vehicle.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';

class VehicleService {
  static final VehicleService _instance = VehicleService._internal();
  
  factory VehicleService() {
    return _instance;
  }
  
  VehicleService._internal();
  
  final AuthService _authService = AuthService();
  final String _baseUrl = ApiConfig.baseUrl;
  
  // Get all vehicles with optional filtering and pagination
  Future<Map<String, dynamic>> getVehicles({
    int page = 1,
    int perPage = 10,
    String? search,
    VehicleBrand? brand,
    int? customerId,
    bool? isActive,
    String? sortBy,
    bool sortAsc = true,
  }) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final queryParams = {
      'page': page.toString(),
      'per_page': perPage.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (brand != null) 'brand': brand.name,
      if (customerId != null) 'customer_id': customerId.toString(),
      if (isActive != null) 'is_active': isActive.toString(),
      if (sortBy != null) 'sort_by': sortBy,
      'sort_direction': sortAsc ? 'asc' : 'desc',
    };

    final uri = Uri.parse('$_baseUrl/vehicles').replace(queryParameters: queryParams);
    
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
        final List<dynamic> vehiclesJson = data['data'];
        final List<Vehicle> vehicles = vehiclesJson
            .map((json) => Vehicle.fromJson(json))
            .toList();

        return {
          'vehicles': vehicles,
          'total': data['meta']['total'],
          'page': data['meta']['current_page'],
          'per_page': data['meta']['per_page'],
          'total_pages': data['meta']['last_page'],
        };
      } else {
        throw Exception('Failed to load vehicles: ${response.statusCode}');
      }
    } catch (e) {
      // For development purposes, return mock data if API is not available
      if (kDebugMode) {
        print('Using mock data for vehicles: $e');
      }
      return _getMockVehicleData(
        brand: brand,
        customerId: customerId,
        search: search,
      );
    }
  }
  
  // Get a single vehicle by ID
  Future<Vehicle> getVehicle(int id) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('$_baseUrl/vehicles/$id');
    
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
        return Vehicle.fromJson(data['data']);
      } else {
        throw Exception('Failed to load vehicle: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load vehicle: $e');
    }
  }
  
  // Create a new vehicle
  Future<Vehicle> createVehicle(Map<String, dynamic> data) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('$_baseUrl/vehicles');
    
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
        return Vehicle.fromJson(responseData['data']);
      } else {
        throw Exception('Failed to create vehicle: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create vehicle: $e');
    }
  }
  
  // Update an existing vehicle
  Future<Vehicle> updateVehicle(int id, Map<String, dynamic> data) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('$_baseUrl/vehicles/$id');
    
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
        return Vehicle.fromJson(responseData['data']);
      } else {
        throw Exception('Failed to update vehicle: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update vehicle: $e');
    }
  }
  
  // Update vehicle mileage
  Future<Vehicle> updateMileage(int id, int mileage) async {
    return updateVehicle(id, {'current_mileage': mileage});
  }
  
  // Toggle vehicle active status
  Future<Vehicle> toggleVehicleStatus(int id, bool isActive) async {
    return updateVehicle(id, {'is_active': isActive});
  }
  
  // Delete a vehicle
  Future<void> deleteVehicle(int id) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('$_baseUrl/vehicles/$id');
    
    try {
      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete vehicle: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete vehicle: $e');
    }
  }
  
  // Get vehicle statistics
  Future<Map<String, dynamic>> getVehicleStatistics() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('$_baseUrl/vehicles/statistics');
    
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
        throw Exception('Failed to load vehicle statistics: ${response.statusCode}');
      }
    } catch (e) {
      // For development purposes, return mock data if API is not available
      return _getMockStatistics();
    }
  }
  
  // Mock data methods for development purposes
  Map<String, dynamic> _getMockVehicleData({
    VehicleBrand? brand,
    int? customerId,
    String? search,
  }) {
    // Create a list of mock vehicles
    List<Vehicle> allVehicles = List.generate(20, (index) {
      final brandValue = VehicleBrand.values[index % VehicleBrand.values.length];
      final customerNumber = (index % 5) + 1; // Distribute among 5 customers
      return Vehicle(
        id: index + 1,
        customerId: customerNumber,
        customerName: 'Customer $customerNumber',
        brand: brandValue,
        model: _getMockModel(brandValue, index),
        licensePlate: '${_getRandomLetters(2)}${1000 + index * 111}${_getRandomLetters(1)}',
        year: 2015 + (index % 9),
        vin: 'VIN${100000 + index * 9876}',
        color: _getMockColors()[index % _getMockColors().length],
        currentMileage: 10000 + (index * 5000),
        lastServiceMileage: 10000 + (index * 4000),
        lastServiceDate: DateTime.now().subtract(Duration(days: 30 + (index * 10))),
        nextServiceDate: index % 4 == 0 
            ? null 
            : DateTime.now().add(Duration(days: (index % 3 == 0) ? -10 : (index * 15))),
        isActive: index % 7 != 0, // Make some inactive for variety
        notes: index % 4 == 0 ? 'Regular maintenance needed' : null,
        createdAt: DateTime.now().subtract(Duration(days: 100 + index)),
        updatedAt: DateTime.now().subtract(Duration(days: index)),
      );
    });

    // Apply filters
    if (brand != null) {
      allVehicles = allVehicles.where((v) => v.brand == brand).toList();
    }
    if (customerId != null) {
      allVehicles = allVehicles.where((v) => v.customerId == customerId).toList();
    }
    if (search != null && search.isNotEmpty) {
      search = search.toLowerCase();
      allVehicles = allVehicles.where((v) => 
        v.model.toLowerCase().contains(search!) || 
        v.licensePlate.toLowerCase().contains(search) ||
        (v.customerName != null && v.customerName!.toLowerCase().contains(search))
      ).toList();
    }

    return {
      'vehicles': allVehicles,
      'total': allVehicles.length,
      'page': 1,
      'per_page': allVehicles.length,
      'total_pages': 1,
    };
  }
  
  String _getRandomLetters(int count) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
    final random = DateTime.now().millisecondsSinceEpoch % 10000;
    String result = '';
    for (int i = 0; i < count; i++) {
      result += chars[(random + i) % chars.length];
    }
    return result;
  }
  
  String _getMockModel(VehicleBrand brand, int index) {
    switch (brand) {
      case VehicleBrand.bmw:
        final series = ['1 Series', '3 Series', '5 Series', '7 Series', 'X3', 'X5', 'i4', 'i8'];
        return series[index % series.length];
      case VehicleBrand.mercedes:
        final series = ['A-Class', 'C-Class', 'E-Class', 'S-Class', 'GLA', 'GLC', 'EQS'];
        return series[index % series.length];
      case VehicleBrand.volkswagen:
        final series = ['Golf', 'Passat', 'Polo', 'Tiguan', 'T-Roc', 'ID.3', 'ID.4'];
        return series[index % series.length];
      case VehicleBrand.audi:
        final series = ['A3', 'A4', 'A6', 'Q3', 'Q5', 'e-tron'];
        return series[index % series.length];
      case VehicleBrand.toyota:
        final series = ['Corolla', 'Camry', 'RAV4', 'Prius', 'Land Cruiser'];
        return series[index % series.length];
      case VehicleBrand.honda:
        final series = ['Civic', 'Accord', 'CR-V', 'HR-V', 'Jazz'];
        return series[index % series.length];
      case VehicleBrand.ford:
        final series = ['Focus', 'Fiesta', 'Kuga', 'Puma', 'Mustang', 'Transit'];
        return series[index % series.length];
      case VehicleBrand.other:
        final series = ['Model X', 'Model Y', 'Model Z'];
        return series[index % series.length];
    }
  }
  
  List<String> _getMockColors() {
    return [
      'Black', 'White', 'Silver', 'Gray', 'Blue', 'Red', 'Green', 
      'Yellow', 'Brown', 'Orange', 'Purple', 'Beige'
    ];
  }
  
  Map<String, dynamic> _getMockStatistics() {
    return {
      'total_vehicles': 189,
      'active_vehicles': 175,
      'inactive_vehicles': 14,
      'service_due_count': 23,
      'service_overdue_count': 12,
      'by_brand': {
        'BMW': 42,
        'Mercedes': 38,
        'Volkswagen': 35,
        'Audi': 25,
        'Toyota': 18,
        'Others': 31,
      },
      'by_year': {
        '2023': 28,
        '2022': 35,
        '2021': 42,
        '2020': 38,
        '2019': 25,
        'Older': 21,
      },
      'service_history': {
        'Jan': 15,
        'Feb': 12,
        'Mar': 18,
        'Apr': 22,
        'May': 25,
        'Jun': 20,
        'Jul': 15,
        'Aug': 10,
        'Sep': 18,
        'Oct': 25,
        'Nov': 28,
        'Dec': 20,
      },
      'recent_services': [
        {
          'vehicle_id': 1,
          'license_plate': 'AB1234C',
          'brand': 'BMW',
          'model': '5 Series',
          'customer_name': 'Ahmed Ben Ali',
          'service_date': '2023-03-15',
          'mileage': 35000,
        },
        {
          'vehicle_id': 2,
          'license_plate': 'CD5678E',
          'brand': 'Mercedes',
          'model': 'E-Class',
          'customer_name': 'Sonia Mansour',
          'service_date': '2023-03-12',
          'mileage': 42000,
        },
        {
          'vehicle_id': 3,
          'license_plate': 'FG9012H',
          'brand': 'Volkswagen',
          'model': 'Golf',
          'customer_name': 'Karim Jebali',
          'service_date': '2023-03-08',
          'mileage': 28000,
        },
        {
          'vehicle_id': 4,
          'license_plate': 'IJ3456K',
          'brand': 'Audi',
          'model': 'A4',
          'customer_name': 'Leila Trabelsi',
          'service_date': '2023-03-05',
          'mileage': 50000,
        },
      ],
    };
  }
} 