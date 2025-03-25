class Customer {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? address;
  final List<int>? vehicleIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.address,
    this.vehicleIds,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      vehicleIds: json['vehicle_ids'] != null ? List<int>.from(json['vehicle_ids']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'vehicle_ids': vehicleIds,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
} 