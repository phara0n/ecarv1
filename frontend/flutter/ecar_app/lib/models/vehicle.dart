class Vehicle {
  final int id;
  final int customerId;
  final String brand;
  final String model;
  final int year;
  final String licensePlate;
  final String? vin;
  final int? currentMileage;
  final double? averageDailyUsage;
  final DateTime? nextServiceDueDate;
  final int? daysUntilNextService;
  
  Vehicle({
    required this.id,
    required this.customerId,
    required this.brand,
    required this.model,
    required this.year,
    required this.licensePlate,
    this.vin,
    this.currentMileage,
    this.averageDailyUsage,
    this.nextServiceDueDate,
    this.daysUntilNextService,
  });
  
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      customerId: json['customer_id'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      licensePlate: json['license_plate'],
      vin: json['vin'],
      currentMileage: json['current_mileage'],
      averageDailyUsage: json['average_daily_usage']?.toDouble(),
      nextServiceDueDate: json['next_service_due_date'] != null 
          ? DateTime.parse(json['next_service_due_date']) 
          : null,
      daysUntilNextService: json['days_until_next_service'],
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
      'vin': vin,
      'current_mileage': currentMileage,
      'average_daily_usage': averageDailyUsage,
    };
  }
} 