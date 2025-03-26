import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/report_data.dart';
import '../config/api_config.dart';

class ReportsService {
  final String _baseUrl = ApiConfig.baseUrl;

  Future<ReportData> getReportData({
    required String reportType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/reports?type=$reportType&start_date=${startDate.toIso8601String()}&end_date=${endDate.toIso8601String()}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ReportData.fromJson(data);
      } else {
        throw Exception('Failed to load report data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching report data: $e');
    }
  }

  Future<ServiceStats> getServiceStats() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/reports/service_stats'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ServiceStats.fromJson(data);
      } else {
        throw Exception('Failed to load service stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching service stats: $e');
    }
  }

  Future<List<RevenueData>> getRevenueData({
    required String period,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/reports/revenue?period=$period&start_date=${startDate.toIso8601String()}&end_date=${endDate.toIso8601String()}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => RevenueData.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load revenue data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching revenue data: $e');
    }
  }

  Future<List<PopularService>> getPopularServices() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/reports/popular_services'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => PopularService.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load popular services: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching popular services: $e');
    }
  }

  Future<List<CustomerStats>> getCustomerStats() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/reports/customer_stats'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => CustomerStats.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load customer stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching customer stats: $e');
    }
  }

  Future<List<VehicleStats>> getVehicleStats() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/reports/vehicle_stats'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => VehicleStats.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load vehicle stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching vehicle stats: $e');
    }
  }
} 