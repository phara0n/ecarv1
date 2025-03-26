import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Customer {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? city;
  final String? postalCode;
  final int vehicleCount;
  final int repairCount;
  final double totalSpent;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String? notes;
  final String? profileImageUrl;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.city,
    this.postalCode,
    required this.vehicleCount,
    required this.repairCount,
    required this.totalSpent,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    this.notes,
    this.profileImageUrl,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      postalCode: json['postal_code'] as String?,
      vehicleCount: json['vehicle_count'] as int? ?? 0,
      repairCount: json['repair_count'] as int? ?? 0,
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
      notes: json['notes'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'postal_code': postalCode,
      'is_active': isActive,
      'notes': notes,
    };
  }

  // Helper method to format the customer's total spent
  String formattedTotalSpent() {
    return NumberFormat.currency(symbol: 'TND ', decimalDigits: 2).format(totalSpent);
  }

  // Helper method to format the customer's date
  String formattedCreatedAt() {
    return DateFormat('MMM d, yyyy').format(createdAt);
  }

  // Helper method to get customer status color
  static Color getStatusColor(bool isActive) {
    return isActive ? Colors.green : Colors.red;
  }

  // Helper method to get customer status text
  static String getStatusText(bool isActive) {
    return isActive ? 'Active' : 'Inactive';
  }

  // Helper for getting the first letter for avatar
  String get initials {
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  // Get avatar widget for customer
  Widget getAvatar({double radius = 20}) {
    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(profileImageUrl!),
      );
    } else {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.blue.shade800,
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: radius * 0.7,
          ),
        ),
      );
    }
  }
} 