import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/invoice.dart';
import 'auth_service.dart';

class InvoiceService {
  final String baseUrl = 'http://localhost:3000/api/v1';
  final AuthService _authService = AuthService();
  
  Future<List<Invoice>> getInvoices() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }
    
    final response = await http.get(
      Uri.parse('$baseUrl/invoices'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Invoice.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load invoices');
    }
  }
  
  Future<Invoice> getInvoice(int id) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }
    
    final response = await http.get(
      Uri.parse('$baseUrl/invoices/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Invoice.fromJson(data);
    } else {
      throw Exception('Failed to load invoice');
    }
  }
  
  Future<void> downloadInvoice(int id) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }
    
    final response = await http.get(
      Uri.parse('$baseUrl/invoices/$id/download'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to download invoice');
    }
    
    // In a real app, we would save the PDF file to the device or open it
    // For now, we'll just return to indicate success
    return;
  }
} 