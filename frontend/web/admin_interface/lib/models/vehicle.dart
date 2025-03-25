class Vehicle {
  final int id;
  final int customerId;
  final String brand;
  final String model;
  final int year;
  final String licensePlate;
  final int currentMileage;
  final double averageDailyUsage;
  final DateTime lastServiceDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  String? customerName; // Optional field for display purposes

  Vehicle({
    required this.id,
    required this.customerId,
    required this.brand,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.currentMileage,
    required this.averageDailyUsage,
    required this.lastServiceDate,
    required this.createdAt,
    required this.updatedAt,
    this.customerName,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      customerId: json['customer_id'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      licensePlate: json['license_plate'],
      currentMileage: json['current_mileage'],
      averageDailyUsage: json['average_daily_usage']?.toDouble() ?? 0.0,
      lastServiceDate: DateTime.parse(json['last_service_date'] ?? json['created_at']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      customerName: json['customer_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'brand': brand,
      'model': model,
      'year': year,
      'license_plate': licensePlate,
      'current_mileage': currentMileage,
      'average_daily_usage': averageDailyUsage,
      'last_service_date': lastServiceDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Method to estimate days until next service based on mileage
  int estimatedDaysUntilNextService({int serviceIntervalKm = 10000}) {
    if (averageDailyUsage <= 0) return 365; // Default to a year if no usage data
    
    // Calculate remaining kilometers until next service
    final int kmSinceLastService = currentMileage - (lastServiceDate.difference(createdAt).inDays * averageDailyUsage).round();
    final int remainingKm = serviceIntervalKm - (kmSinceLastService % serviceIntervalKm);
    
    // Convert to days based on average usage
    return (remainingKm / averageDailyUsage).ceil();
  }
} 