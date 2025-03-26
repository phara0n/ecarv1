import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard_data.dart';
import '../config/api_config.dart';

class DashboardService {
  final String _baseUrl = ApiConfig.baseUrl;

  Future<DashboardData> getDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/dashboard'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return DashboardData.fromJson(data);
      } else {
        throw Exception('Failed to load dashboard data');
      }
    } catch (e) {
      throw Exception('Error fetching dashboard data: $e');
    }
  }
} 