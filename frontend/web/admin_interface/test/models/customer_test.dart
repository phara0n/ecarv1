import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:admin_interface/models/customer.dart';

void main() {
  group('Customer Model Tests', () {
    test('Customer fromJson and toJson', () {
      final dateTime = DateTime(2023, 3, 15);
      
      final Map<String, dynamic> json = {
        'id': 1,
        'name': 'John Doe',
        'email': 'john.doe@example.com',
        'phone': '+216 29 123 456',
        'address': '15 Rue de Carthage, Tunis',
        'city': 'Tunis',
        'is_active': true,
        'vehicle_count': 3,
        'total_spent': 2500.50,
        'created_at': '2023-03-15T00:00:00.000Z',
        'updated_at': '2023-03-15T00:00:00.000Z',
      };
      
      final customer = Customer.fromJson(json);
      
      expect(customer.id, 1);
      expect(customer.name, 'John Doe');
      expect(customer.email, 'john.doe@example.com');
      expect(customer.phone, '+216 29 123 456');
      expect(customer.address, '15 Rue de Carthage, Tunis');
      expect(customer.city, 'Tunis');
      expect(customer.isActive, true);
      expect(customer.vehicleCount, 3);
      expect(customer.totalSpent, 2500.50);
      expect(customer.createdAt.year, dateTime.year);
      expect(customer.createdAt.month, dateTime.month);
      expect(customer.createdAt.day, dateTime.day);
      
      final jsonResult = customer.toJson();
      
      expect(jsonResult['name'], 'John Doe');
      expect(jsonResult['email'], 'john.doe@example.com');
      expect(jsonResult['phone'], '+216 29 123 456');
      expect(jsonResult['address'], '15 Rue de Carthage, Tunis');
      expect(jsonResult['city'], 'Tunis');
      expect(jsonResult['is_active'], true);
    });
    
    test('Customer status helpers', () {
      final activeCustomer = Customer(
        id: 1,
        name: 'John Doe',
        email: 'john.doe@example.com',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final inactiveCustomer = Customer(
        id: 2,
        name: 'Jane Smith',
        email: 'jane.smith@example.com',
        isActive: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Test status text
      expect(Customer.getStatusText(true), 'Active');
      expect(Customer.getStatusText(false), 'Inactive');
      
      // Test status colors
      expect(Customer.getStatusColor(true), Colors.green);
      expect(Customer.getStatusColor(false), Colors.red);
    });
    
    test('Customer formatting methods', () {
      final customer = Customer(
        id: 1,
        name: 'John Doe',
        email: 'john.doe@example.com',
        totalSpent: 2500.50,
        createdAt: DateTime(2023, 3, 15),
        updatedAt: DateTime(2023, 3, 15),
      );
      
      expect(customer.formattedCreatedAt(), 'Mar 15, 2023');
      expect(customer.formattedTotalSpent(), 'TD 2,500.50');
    });
    
    test('Customer avatar generator', () {
      final customer1 = Customer(
        id: 1,
        name: 'John Doe',
        email: 'john.doe@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final customer2 = Customer(
        id: 2,
        name: 'Jane Smith',
        email: 'jane.smith@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final customer3 = Customer(
        id: 3,
        name: '',
        email: 'anonymous@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Test initials generation
      expect(customer1.getInitials(), 'JD');
      expect(customer2.getInitials(), 'JS');
      expect(customer3.getInitials(), 'A');
    });
  });
} 