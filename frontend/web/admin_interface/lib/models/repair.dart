import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Extension method for String capitalization
extension StringExtension on String {
  String capitalize() {
    return isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  }
}

class Repair {
  final int id;
  final int vehicleId;
  final int customerId;
  final String vehicleBrand;
  final String vehicleModel;
  final String description;
  final DateTime date;
  final double cost;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Optional fields for display purposes
  String? licensePlate;
  String? customerName;
  
  Repair({
    required this.id,
    required this.vehicleId,
    required this.customerId,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.description,
    required this.date,
    required this.cost,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.licensePlate,
    this.customerName,
  });
  
  factory Repair.fromJson(Map<String, dynamic> json) {
    return Repair(
      id: json['id'] as int,
      vehicleId: json['vehicle_id'] as int,
      customerId: json['customer_id'] as int,
      vehicleBrand: json['vehicle_brand'] as String? ?? 'Unknown',
      vehicleModel: json['vehicle_model'] as String? ?? 'Unknown',
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      cost: (json['cost'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      licensePlate: json['license_plate'],
      customerName: json['customer_name'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'customer_id': customerId,
      'vehicle_brand': vehicleBrand,
      'vehicle_model': vehicleModel,
      'description': description,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'cost': cost,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Get a color based on repair status
  static Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  // Get a user-friendly status name
  static String getStatusName(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }
  
  // Get available status options for dropdown
  static List<String> getStatusOptions() {
    return ['pending', 'in_progress', 'completed', 'cancelled'];
  }
}