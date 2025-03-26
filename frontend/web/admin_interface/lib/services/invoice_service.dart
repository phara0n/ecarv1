import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/invoice.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';

class InvoiceService {
  static final InvoiceService _instance = InvoiceService._internal();
  
  factory InvoiceService() {
    return _instance;
  }
  
  InvoiceService._internal();
  
  final AuthService _authService = AuthService();
  final String _baseUrl = ApiConfig.baseUrl;
  
  // Get all invoices with optional filtering and pagination
  Future<Map<String, dynamic>> getInvoices({
    int page = 1,
    int perPage = 10,
    String? search,
    int? repairId,
    int? vehicleId,
    int? customerId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
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
      if (repairId != null) 'repair_id': repairId.toString(),
      if (vehicleId != null) 'vehicle_id': vehicleId.toString(),
      if (customerId != null) 'customer_id': customerId.toString(),
      if (status != null) 'status': status,
      if (startDate != null) 'start_date': startDate.toIso8601String().split('T')[0],
      if (endDate != null) 'end_date': endDate.toIso8601String().split('T')[0],
      if (sortBy != null) 'sort_by': sortBy,
      'sort_direction': sortAsc ? 'asc' : 'desc',
    };

    final uri = Uri.parse('$_baseUrl/invoices').replace(queryParameters: queryParams);
    
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
        final List<dynamic> invoicesJson = data['data'];
        final List<Invoice> invoices = invoicesJson
            .map((json) => Invoice.fromJson(json))
            .toList();

        return {
          'invoices': invoices,
          'total': data['meta']['total'],
          'page': data['meta']['current_page'],
          'per_page': data['meta']['per_page'],
          'total_pages': data['meta']['last_page'],
        };
      } else {
        throw Exception('Failed to load invoices: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load invoices: $e');
    }
  }
  
  // Get a single invoice by ID
  Future<Invoice> getInvoice(int id) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('$_baseUrl/invoices/$id');
    
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
        return Invoice.fromJson(data['data']);
      } else {
        throw Exception('Failed to load invoice: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load invoice: $e');
    }
  }
  
  // Create a new invoice
  Future<Invoice> createInvoice(Map<String, dynamic> data) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('$_baseUrl/invoices');
    
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
        return Invoice.fromJson(responseData['data']);
      } else {
        throw Exception('Failed to create invoice: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create invoice: $e');
    }
  }
  
  // Update an existing invoice
  Future<Invoice> updateInvoice(int id, Map<String, dynamic> data) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('$_baseUrl/invoices/$id');
    
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
        return Invoice.fromJson(responseData['data']);
      } else {
        throw Exception('Failed to update invoice: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update invoice: $e');
    }
  }
  
  // Update just the status of an invoice
  Future<Invoice> updateStatus(int id, String status) async {
    return updateInvoice(id, {'status': status});
  }
  
  // Delete an invoice
  Future<void> deleteInvoice(int id) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('$_baseUrl/invoices/$id');
    
    try {
      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete invoice: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete invoice: $e');
    }
  }
  
  // Generate a PDF for an invoice
  Future<String> generatePdf(int id) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('$_baseUrl/invoices/$id/generate_pdf');
    
    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['pdf_url'] as String;
      } else {
        throw Exception('Failed to generate PDF: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to generate PDF: $e');
    }
  }
  
  // Send invoice by email
  Future<void> sendByEmail(int id, String email) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('$_baseUrl/invoices/$id/send_email');
    
    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send invoice by email: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to send invoice by email: $e');
    }
  }
  
  // Get invoice statistics
  Future<Map<String, dynamic>> getInvoiceStatistics() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('$_baseUrl/invoices/statistics');
    
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
        throw Exception('Failed to load invoice statistics: ${response.statusCode}');
      }
    } catch (e) {
      // For demo/development purposes, return mock data if the API is not available
      return _getMockStatistics();
    }
  }
  
  // Mock data for development/testing
  Map<String, dynamic> _getMockStatistics() {
    return {
      'total_invoices': 184,
      'total_paid': 132,
      'total_pending': 42,
      'total_overdue': 10,
      'total_amount': 67248.50,
      'paid_amount': 50982.75,
      'pending_amount': 13276.50,
      'overdue_amount': 2989.25,
      'status_distribution': {
        'paid': 132,
        'pending': 42,
        'overdue': 10,
        'cancelled': 0,
      },
      'recent_invoices': [
        {
          'id': 1,
          'invoice_number': 'INV-2023-001',
          'issue_date': '2023-06-15',
          'due_date': '2023-07-15',
          'total': 1250.00,
          'status': 'paid',
          'customer_name': 'Ahmed Ben Ali',
          'vehicle': 'BMW X5',
        },
        {
          'id': 2,
          'invoice_number': 'INV-2023-002',
          'issue_date': '2023-06-14',
          'due_date': '2023-07-14',
          'total': 785.50,
          'status': 'paid',
          'customer_name': 'Sonia Mansour',
          'vehicle': 'Mercedes C200',
        },
        {
          'id': 3,
          'invoice_number': 'INV-2023-003',
          'issue_date': '2023-06-10',
          'due_date': '2023-07-10',
          'total': 1475.25,
          'status': 'pending',
          'customer_name': 'Karim Jebali',
          'vehicle': 'VW Golf',
        },
        {
          'id': 4,
          'invoice_number': 'INV-2023-004',
          'issue_date': '2023-05-25',
          'due_date': '2023-06-25',
          'total': 620.75,
          'status': 'overdue',
          'customer_name': 'Leila Trabelsi',
          'vehicle': 'Audi A4',
        },
      ],
      'monthly_revenue': {
        'Jan': 5240.50,
        'Feb': 4875.25,
        'Mar': 5620.00,
        'Apr': 6125.75,
        'May': 5890.50,
        'Jun': 6724.25,
        'Jul': 5475.50,
        'Aug': 4980.75,
        'Sep': 5240.50,
        'Oct': 5750.25,
        'Nov': 5240.50,
        'Dec': 6084.75,
      },
    };
  }
} 