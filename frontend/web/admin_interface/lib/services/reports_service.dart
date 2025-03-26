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
        final Map<String, dynamic> data = json.decode(response.body);
        return ReportData.fromJson(data);
      } else {
        throw Exception('Failed to load report data');
      }
    } catch (e) {
      throw Exception('Error fetching report data: $e');
    }
  }

  Future<List<ServiceStat>> getServiceStats() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/reports/service_stats'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ServiceStat.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load service stats');
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
        return data.map((json) => RevenueData.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load revenue data');
      }
    } catch (e) {
      throw Exception('Error fetching revenue data: $e');
    }
  }
} 