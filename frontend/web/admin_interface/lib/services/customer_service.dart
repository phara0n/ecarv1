import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/customer.dart';
import 'auth_service.dart';

class CustomerService {
  static final CustomerService _instance = CustomerService._internal();
  
  factory CustomerService() {
    return _instance;
  }
  
  CustomerService._internal();
  
  final AuthService _authService = AuthService();
  final String _baseUrl = 'https://api.ecar.tn/api/v1';
  
  // Get all customers with pagination
  Future<Map<String, dynamic>> getCustomers({
    int page = 1,
    int perPage = 10,
    String? search,
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
        if (sortBy != null && sortBy.isNotEmpty) 'sort_by': sortBy,
        'sort_asc': sortAsc.toString(),
      };
      
      final uri = Uri.parse('$_baseUrl/admin/customers').replace(
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
        
        final customers = (data['customers'] as List)
            .map((json) => Customer.fromJson(json))
            .toList();
        
        return {
          'customers': customers,
          'total': data['total'],
          'page': data['page'],
          'per_page': data['per_page'],
          'total_pages': data['total_pages'],
        };
      } else if (response.statusCode == 401) {
        // Try to refresh token and retry
        final newToken = await _authService.refreshToken();
        
        if (newToken != null) {
          return getCustomers(
            page: page,
            perPage: perPage,
            search: search,
            sortBy: sortBy,
            sortAsc: sortAsc,
          );
        } else {
          throw Exception('Authentication expired');
        }
      } else {
        throw Exception('Failed to load customers: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error getting customers: $e');
      rethrow;
    }
  }
  
  // Get a single customer by ID
  Future<Customer> getCustomer(int id) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/customers/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Customer.fromJson(data);
      } else if (response.statusCode == 401) {
        // Try to refresh token and retry
        final newToken = await _authService.refreshToken();
        
        if (newToken != null) {
          return getCustomer(id);
        } else {
          throw Exception('Authentication expired');
        }
      } else {
        throw Exception('Failed to load customer: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error getting customer: $e');
      rethrow;
    }
  }
  
  // Create a new customer
  Future<Customer> createCustomer(Map<String, dynamic> customerData) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/customers'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(customerData),
      );
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Customer.fromJson(data);
      } else if (response.statusCode == 401) {
        // Try to refresh token and retry
        final newToken = await _authService.refreshToken();
        
        if (newToken != null) {
          return createCustomer(customerData);
        } else {
          throw Exception('Authentication expired');
        }
      } else {
        throw Exception('Failed to create customer: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error creating customer: $e');
      rethrow;
    }
  }
  
  // Update an existing customer
  Future<Customer> updateCustomer(int id, Map<String, dynamic> customerData) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await http.put(
        Uri.parse('$_baseUrl/admin/customers/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(customerData),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Customer.fromJson(data);
      } else if (response.statusCode == 401) {
        // Try to refresh token and retry
        final newToken = await _authService.refreshToken();
        
        if (newToken != null) {
          return updateCustomer(id, customerData);
        } else {
          throw Exception('Authentication expired');
        }
      } else {
        throw Exception('Failed to update customer: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error updating customer: $e');
      rethrow;
    }
  }
  
  // Delete a customer
  Future<bool> deleteCustomer(int id) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await http.delete(
        Uri.parse('$_baseUrl/admin/customers/$id'),
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
          return deleteCustomer(id);
        } else {
          throw Exception('Authentication expired');
        }
      } else {
        throw Exception('Failed to delete customer: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error deleting customer: $e');
      rethrow;
    }
  }
} 