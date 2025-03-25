import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/customer.dart';
import '../services/auth_service.dart';

class CustomerService {
  static final CustomerService _instance = CustomerService._internal();
  
  factory CustomerService() {
    return _instance;
  }
  
  CustomerService._internal();
  
  final AuthService _authService = AuthService();
  final String _baseUrl = 'https://api.ecar.tn/api/v1';
  
  // Get all customers with optional filtering and pagination
  Future<Map<String, dynamic>> getCustomers({
    int page = 1,
    int perPage = 10,
    String? search,
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
      if (isActive != null) 'is_active': isActive.toString(),
      if (sortBy != null) 'sort_by': sortBy,
      'sort_direction': sortAsc ? 'asc' : 'desc',
    };

    final uri = Uri.parse('$_baseUrl/customers').replace(queryParameters: queryParams);
    
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
        final List<dynamic> customersJson = data['data'];
        final List<Customer> customers = customersJson
            .map((json) => Customer.fromJson(json))
            .toList();

        return {
          'customers': customers,
          'total': data['meta']['total'],
          'page': data['meta']['current_page'],
          'per_page': data['meta']['per_page'],
          'total_pages': data['meta']['last_page'],
        };
      } else {
        throw Exception('Failed to load customers: ${response.statusCode}');
      }
    } catch (e) {
      // For development purposes, return mock data if API is not available
      return _getMockCustomerData();
    }
  }
  
  // Get a single customer by ID
  Future<Customer> getCustomer(int id) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('$_baseUrl/customers/$id');
    
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
        return Customer.fromJson(data['data']);
      } else {
        throw Exception('Failed to load customer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load customer: $e');
    }
  }
  
  // Create a new customer
  Future<Customer> createCustomer(Map<String, dynamic> data) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('$_baseUrl/customers');
    
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
        return Customer.fromJson(responseData['data']);
      } else {
        throw Exception('Failed to create customer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create customer: $e');
    }
  }
  
  // Update an existing customer
  Future<Customer> updateCustomer(int id, Map<String, dynamic> data) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('$_baseUrl/customers/$id');
    
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
        return Customer.fromJson(responseData['data']);
      } else {
        throw Exception('Failed to update customer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update customer: $e');
    }
  }
  
  // Toggle customer active status
  Future<Customer> toggleCustomerStatus(int id, bool isActive) async {
    return updateCustomer(id, {'is_active': isActive});
  }
  
  // Delete a customer
  Future<void> deleteCustomer(int id) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('$_baseUrl/customers/$id');
    
    try {
      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete customer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete customer: $e');
    }
  }
  
  // Get customer statistics
  Future<Map<String, dynamic>> getCustomerStatistics() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('$_baseUrl/customers/statistics');
    
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
        throw Exception('Failed to load customer statistics: ${response.statusCode}');
      }
    } catch (e) {
      // For development purposes, return mock data if API is not available
      return _getMockStatistics();
    }
  }
  
  // Mock data methods for development purposes
  Map<String, dynamic> _getMockCustomerData() {
    final List<Customer> mockCustomers = List.generate(15, (index) {
      return Customer(
        id: index + 1,
        name: _mockNames[index % _mockNames.length],
        email: 'customer${index + 1}@example.com',
        phone: '+216 ${_getRandomPhone()}',
        address: 'Address ${index + 1}, Tunis',
        city: _mockCities[index % _mockCities.length],
        postalCode: '${1000 + index * 10}',
        vehicleCount: 1 + (index % 3),
        repairCount: 2 + (index % 5),
        totalSpent: 500.0 + (index * 200),
        createdAt: DateTime.now().subtract(Duration(days: 30 + index * 5)),
        updatedAt: DateTime.now().subtract(Duration(days: index * 2)),
        isActive: index % 7 != 0, // Make some inactive for variety
        notes: index % 3 == 0 ? 'VIP Customer' : null,
        profileImageUrl: null,
      );
    });

    return {
      'customers': mockCustomers,
      'total': 35,
      'page': 1,
      'per_page': 15,
      'total_pages': 3,
    };
  }
  
  String _getRandomPhone() {
    final numbers = List.generate(8, (index) => (1 + (index * 7) % 9).toString()).join('');
    return '${numbers.substring(0, 2)} ${numbers.substring(2, 5)} ${numbers.substring(5)}';
  }
  
  final List<String> _mockNames = [
    'Ahmed Ben Ali',
    'Sonia Mansour',
    'Mohamed Karim',
    'Leila Trabelsi',
    'Hedi Majri',
    'Fatma Kassem',
    'Ali Hassan',
    'Yasmine Taleb',
    'Karim Jebali',
    'Amina Selmi',
    'Nabil Gabtni',
    'Rania Chaaben',
    'Tarek Sfar',
    'Salma Riahi',
    'Jamel Khediri',
  ];
  
  final List<String> _mockCities = [
    'Tunis',
    'Sfax',
    'Sousse',
    'Kairouan',
    'Bizerte',
    'Gabès',
    'Ariana',
    'Gafsa',
    'Monastir',
    'Ben Arous',
  ];
  
  Map<String, dynamic> _getMockStatistics() {
    return {
      'total_customers': 145,
      'active_customers': 128,
      'inactive_customers': 17,
      'new_last_month': 12,
      'total_revenue': 94250.75,
      'average_revenue_per_customer': 650.0,
      'top_cities': {
        'Tunis': 45,
        'Sousse': 28,
        'Sfax': 22,
        'Bizerte': 15,
        'Monastir': 13,
      },
      'vehicles_per_customer': {
        '1': 86,
        '2': 42,
        '3+': 17,
      },
      'recent_customers': [
        {
          'id': 1,
          'name': 'Ahmed Ben Ali',
          'email': 'ahmed.benali@gmail.com',
          'created_at': '2023-03-15',
          'vehicle_count': 2,
          'is_active': true,
        },
        {
          'id': 2,
          'name': 'Sonia Mansour',
          'email': 'sonia.mansour@gmail.com',
          'created_at': '2023-03-14',
          'vehicle_count': 1,
          'is_active': true,
        },
        {
          'id': 3,
          'name': 'Karim Jebali',
          'email': 'karim.jebali@gmail.com',
          'created_at': '2023-03-10',
          'vehicle_count': 3,
          'is_active': true,
        },
        {
          'id': 4,
          'name': 'Leila Trabelsi',
          'email': 'leila.trabelsi@gmail.com',
          'created_at': '2023-03-05',
          'vehicle_count': 1,
          'is_active': false,
        },
      ],
      'customer_growth': {
        'Jan': 8,
        'Feb': 10,
        'Mar': 12,
        'Apr': 9,
        'May': 15,
        'Jun': 18,
        'Jul': 14,
        'Aug': 9,
        'Sep': 11,
        'Oct': 13,
        'Nov': 10,
        'Dec': 16,
      },
    };
  }
} 