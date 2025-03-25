class Customer {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? address;
  
  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.address,
  });
  
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
    };
  }
} 