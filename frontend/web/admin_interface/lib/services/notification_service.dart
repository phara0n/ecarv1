import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification.dart';
import '../config/api_config.dart';

class NotificationService {
  final String _baseUrl = ApiConfig.baseUrl;

  Future<List<Notification>> getNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/notifications'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Notification.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/notifications/$notificationId/read'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification as read');
      }
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/notifications/$notificationId'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete notification');
      }
    } catch (e) {
      throw Exception('Error deleting notification: $e');
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/notifications'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to clear notifications');
      }
    } catch (e) {
      throw Exception('Error clearing notifications: $e');
    }
  }
} 