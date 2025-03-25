import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'customer.dart';

enum VehicleBrand {
  bmw,
  mercedes,
  volkswagen,
  audi,
  toyota,
  honda,
  ford,
  other
}

enum ServiceStatus {
  upToDate,
  due,
  overdue,
  unknown
}

class Vehicle {
  final int id;
  final int customerId;
  final String? customerName;
  final VehicleBrand brand;
  final String model;
  final String licensePlate;
  final int year;
  final String? vin;
  final String? color;
  final int currentMileage;
  final int lastServiceMileage;
  final DateTime lastServiceDate;
  final DateTime? nextServiceDate;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    required this.id,
    required this.customerId,
    this.customerName,
    required this.brand,
    required this.model,
    required this.licensePlate,
    required this.year,
    this.vin,
    this.color,
    required this.currentMileage,
    required this.lastServiceMileage,
    required this.lastServiceDate,
    this.nextServiceDate,
    required this.isActive,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as int,
      customerId: json['customer_id'] as int,
      customerName: json['customer_name'] as String?,
      brand: _brandFromString(json['brand'] as String),
      model: json['model'] as String,
      licensePlate: json['license_plate'] as String,
      year: json['year'] as int,
      vin: json['vin'] as String?,
      color: json['color'] as String?,
      currentMileage: json['current_mileage'] as int,
      lastServiceMileage: json['last_service_mileage'] as int,
      lastServiceDate: DateTime.parse(json['last_service_date'] as String),
      nextServiceDate: json['next_service_date'] != null 
          ? DateTime.parse(json['next_service_date'] as String) 
          : null,
      isActive: json['is_active'] as bool? ?? true,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'brand': brand.name,
      'model': model,
      'license_plate': licensePlate,
      'year': year,
      'vin': vin,
      'color': color,
      'current_mileage': currentMileage,
      'last_service_mileage': lastServiceMileage,
      'last_service_date': lastServiceDate.toIso8601String(),
      'next_service_date': nextServiceDate?.toIso8601String(),
      'is_active': isActive,
      'notes': notes,
    };
  }

  // Helper method to calculate service status
  ServiceStatus getServiceStatus() {
    if (nextServiceDate == null) {
      return ServiceStatus.unknown;
    }

    final today = DateTime.now();
    final daysUntilService = nextServiceDate!.difference(today).inDays;

    if (daysUntilService < 0) {
      return ServiceStatus.overdue;
    } else if (daysUntilService <= 14) {
      return ServiceStatus.due;
    } else {
      return ServiceStatus.upToDate;
    }
  }

  // Helper method to get service status text
  String getServiceStatusText() {
    final status = getServiceStatus();
    switch (status) {
      case ServiceStatus.upToDate:
        return 'Up to date';
      case ServiceStatus.due:
        return 'Service due';
      case ServiceStatus.overdue:
        return 'Overdue';
      case ServiceStatus.unknown:
        return 'Unknown';
    }
  }

  // Helper method to get service status color
  Color getServiceStatusColor() {
    final status = getServiceStatus();
    switch (status) {
      case ServiceStatus.upToDate:
        return Colors.green;
      case ServiceStatus.due:
        return Colors.orange;
      case ServiceStatus.overdue:
        return Colors.red;
      case ServiceStatus.unknown:
        return Colors.grey;
    }
  }

  // Format last service date
  String formattedLastServiceDate() {
    return DateFormat('MMM d, yyyy').format(lastServiceDate);
  }

  // Format next service date
  String formattedNextServiceDate() {
    return nextServiceDate != null 
        ? DateFormat('MMM d, yyyy').format(nextServiceDate!)
        : 'Not scheduled';
  }

  // Format mileage
  String formattedMileage() {
    final formatter = NumberFormat('#,###');
    return '${formatter.format(currentMileage)} km';
  }

  // Format creation date
  String formattedCreatedAt() {
    return DateFormat('MMM d, yyyy').format(createdAt);
  }

  // Get brand display name
  String getBrandDisplayName() {
    switch (brand) {
      case VehicleBrand.bmw:
        return 'BMW';
      case VehicleBrand.mercedes:
        return 'Mercedes';
      case VehicleBrand.volkswagen:
        return 'Volkswagen';
      case VehicleBrand.audi:
        return 'Audi';
      case VehicleBrand.toyota:
        return 'Toyota';
      case VehicleBrand.honda:
        return 'Honda';
      case VehicleBrand.ford:
        return 'Ford';
      case VehicleBrand.other:
        return 'Other';
    }
  }

  // Get brand logo
  Widget getBrandLogo({double size = 24.0}) {
    final String assetName;
    
    switch (brand) {
      case VehicleBrand.bmw:
        assetName = 'assets/logos/bmw.png';
        break;
      case VehicleBrand.mercedes:
        assetName = 'assets/logos/mercedes.png';
        break;
      case VehicleBrand.volkswagen:
        assetName = 'assets/logos/volkswagen.png';
        break;
      case VehicleBrand.audi:
        assetName = 'assets/logos/audi.png';
        break;
      case VehicleBrand.toyota:
        assetName = 'assets/logos/toyota.png';
        break;
      case VehicleBrand.honda:
        assetName = 'assets/logos/honda.png';
        break;
      case VehicleBrand.ford:
        assetName = 'assets/logos/ford.png';
        break;
      case VehicleBrand.other:
        return Icon(Icons.directions_car, size: size);
    }
    
    return Image.asset(
      assetName,
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.directions_car, size: size);
      },
    );
  }

  // Get brand color
  Color getBrandColor() {
    switch (brand) {
      case VehicleBrand.bmw:
        return const Color(0xFF0066B1); // BMW Blue
      case VehicleBrand.mercedes:
        return const Color(0xFF9A9A9A); // Mercedes Silver
      case VehicleBrand.volkswagen:
        return const Color(0xFF003399); // VW Blue
      case VehicleBrand.audi:
        return const Color(0xFF000000); // Audi Black
      case VehicleBrand.toyota:
        return const Color(0xFFEB0A1E); // Toyota Red
      case VehicleBrand.honda:
        return const Color(0xFF005CBF); // Honda Blue
      case VehicleBrand.ford:
        return const Color(0xFF003478); // Ford Blue
      case VehicleBrand.other:
        return Colors.grey;
    }
  }

  // Helper for converting string to enum
  static VehicleBrand _brandFromString(String brandName) {
    try {
      return VehicleBrand.values.firstWhere(
        (e) => e.name.toLowerCase() == brandName.toLowerCase(),
      );
    } catch (e) {
      return VehicleBrand.other;
    }
  }
} 