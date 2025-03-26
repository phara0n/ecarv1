import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/customer.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';
import 'package:intl/intl.dart';

class CustomerService {
  static final CustomerService _instance = CustomerService._internal();
  
  factory CustomerService() {
    return _instance;
  }
  
  CustomerService._internal();
  
  final AuthService _authService = AuthService();
  final String _baseUrl = ApiConfig.baseUrl;
  
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
    final customers = List.generate(10, (index) {
      final id = index + 1;
      final isActive = index % 5 != 0;
      final createdAt = DateTime.now().subtract(Duration(days: 30 * (index + 1)));
      
      return Customer(
        id: id,
        name: 'Customer ${id}',
        email: 'customer${id}@example.com',
        phone: '+216 ${50000000 + id * 111111}',
        address: 'Street ${id}',
        city: ['Tunis', 'Sfax', 'Sousse', 'Bizerte', 'Ariana'][index % 5],
        postalCode: '${1000 + index * 100}',
        vehicleCount: 1 + (index % 3),
        repairCount: 2 + (index % 5),
        totalSpent: 500.0 + (index * 250.0),
        createdAt: createdAt,
        updatedAt: createdAt.add(const Duration(days: 5)),
        isActive: isActive,
        notes: isActive ? 'Regular customer' : 'Inactive since ${DateFormat('MMM yyyy').format(createdAt)}',
      );
    });

    return {
      'customers': customers,
      'total': 35,
      'page': 1,
      'per_page': 10,
      'total_pages': 4,
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
      'total_customers': 35,
      'active_customers': 30,
      'inactive_customers': 5,
      'new_customers_last_month': 8,
      'customer_growth_percentage': 12.5,
      'average_vehicles_per_customer': 1.8,
      'average_repairs_per_customer': 3.2,
      'average_total_spent': 1250.75,
      'top_cities': [
        {'name': 'Tunis', 'count': 12},
        {'name': 'Sfax', 'count': 8},
        {'name': 'Sousse', 'count': 6},
        {'name': 'Bizerte', 'count': 5},
        {'name': 'Ariana', 'count': 4}
      ],
      'monthly_new_customers': [
        {'month': 'Jan', 'count': 3},
        {'month': 'Feb', 'count': 4},
        {'month': 'Mar', 'count': 5},
        {'month': 'Apr', 'count': 3},
        {'month': 'May', 'count': 6},
        {'month': 'Jun', 'count': 4},
        {'month': 'Jul', 'count': 5},
        {'month': 'Aug', 'count': 3},
        {'month': 'Sep', 'count': 4},
        {'month': 'Oct', 'count': 5},
        {'month': 'Nov', 'count': 6},
        {'month': 'Dec', 'count': 4}
      ]
    };
  }
} 