import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:admin_interface/models/vehicle.dart';

void main() {
  group('Vehicle Model Tests', () {
    test('Vehicle fromJson and toJson', () {
      final dateTime = DateTime(2023, 3, 15);
      final nextServiceDate = DateTime(2023, 9, 15);
      
      final Map<String, dynamic> json = {
        'id': 1,
        'customer_id': 2,
        'customer_name': 'John Doe',
        'brand': 'bmw',
        'model': '5 Series',
        'license_plate': 'AB123CD',
        'year': 2020,
        'vin': 'WBAJD1234JBK56789',
        'color': 'Black',
        'current_mileage': 25000,
        'last_service_mileage': 20000,
        'last_service_date': '2023-03-15T00:00:00.000Z',
        'next_service_date': '2023-09-15T00:00:00.000Z',
        'is_active': true,
        'notes': 'Regular maintenance',
        'created_at': '2023-03-15T00:00:00.000Z',
        'updated_at': '2023-03-15T00:00:00.000Z',
      };
      
      final vehicle = Vehicle.fromJson(json);
      
      expect(vehicle.id, 1);
      expect(vehicle.customerId, 2);
      expect(vehicle.customerName, 'John Doe');
      expect(vehicle.brand, VehicleBrand.bmw);
      expect(vehicle.model, '5 Series');
      expect(vehicle.licensePlate, 'AB123CD');
      expect(vehicle.year, 2020);
      expect(vehicle.vin, 'WBAJD1234JBK56789');
      expect(vehicle.color, 'Black');
      expect(vehicle.currentMileage, 25000);
      expect(vehicle.lastServiceMileage, 20000);
      expect(vehicle.lastServiceDate.year, dateTime.year);
      expect(vehicle.lastServiceDate.month, dateTime.month);
      expect(vehicle.lastServiceDate.day, dateTime.day);
      expect(vehicle.nextServiceDate!.year, nextServiceDate.year);
      expect(vehicle.nextServiceDate!.month, nextServiceDate.month);
      expect(vehicle.nextServiceDate!.day, nextServiceDate.day);
      expect(vehicle.isActive, true);
      expect(vehicle.notes, 'Regular maintenance');
      
      final jsonResult = vehicle.toJson();
      
      expect(jsonResult['customer_id'], 2);
      expect(jsonResult['brand'], 'bmw');
      expect(jsonResult['model'], '5 Series');
      expect(jsonResult['license_plate'], 'AB123CD');
      expect(jsonResult['year'], 2020);
      expect(jsonResult['vin'], 'WBAJD1234JBK56789');
      expect(jsonResult['color'], 'Black');
      expect(jsonResult['current_mileage'], 25000);
      expect(jsonResult['last_service_mileage'], 20000);
      expect(jsonResult['is_active'], true);
      expect(jsonResult['notes'], 'Regular maintenance');
    });
    
    test('Vehicle service status helpers', () {
      // Up to date service
      final upToDateVehicle = Vehicle(
        id: 1,
        customerId: 1,
        brand: VehicleBrand.bmw,
        model: '5 Series',
        licensePlate: 'AB123CD',
        year: 2020,
        currentMileage: 25000,
        lastServiceMileage: 20000,
        lastServiceDate: DateTime.now().subtract(const Duration(days: 90)),
        nextServiceDate: DateTime.now().add(const Duration(days: 90)),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Due service (due within 14 days)
      final dueVehicle = Vehicle(
        id: 2,
        customerId: 1,
        brand: VehicleBrand.mercedes,
        model: 'E-Class',
        licensePlate: 'EF456GH',
        year: 2019,
        currentMileage: 30000,
        lastServiceMileage: 25000,
        lastServiceDate: DateTime.now().subtract(const Duration(days: 170)),
        nextServiceDate: DateTime.now().add(const Duration(days: 7)),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Overdue service
      final overdueVehicle = Vehicle(
        id: 3,
        customerId: 1,
        brand: VehicleBrand.volkswagen,
        model: 'Golf',
        licensePlate: 'IJ789KL',
        year: 2018,
        currentMileage: 45000,
        lastServiceMileage: 40000,
        lastServiceDate: DateTime.now().subtract(const Duration(days: 200)),
        nextServiceDate: DateTime.now().subtract(const Duration(days: 30)),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Unknown service status (no next service date)
      final unknownVehicle = Vehicle(
        id: 4,
        customerId: 1,
        brand: VehicleBrand.audi,
        model: 'A4',
        licensePlate: 'MN012OP',
        year: 2021,
        currentMileage: 10000,
        lastServiceMileage: 5000,
        lastServiceDate: DateTime.now().subtract(const Duration(days: 30)),
        nextServiceDate: null,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Test service statuses
      expect(upToDateVehicle.getServiceStatus(), ServiceStatus.upToDate);
      expect(dueVehicle.getServiceStatus(), ServiceStatus.due);
      expect(overdueVehicle.getServiceStatus(), ServiceStatus.overdue);
      expect(unknownVehicle.getServiceStatus(), ServiceStatus.unknown);
      
      // Test status text
      expect(upToDateVehicle.getServiceStatusText(), 'Up to date');
      expect(dueVehicle.getServiceStatusText(), 'Service due');
      expect(overdueVehicle.getServiceStatusText(), 'Overdue');
      expect(unknownVehicle.getServiceStatusText(), 'Unknown');
      
      // Test status colors
      expect(upToDateVehicle.getServiceStatusColor(), Colors.green);
      expect(dueVehicle.getServiceStatusColor(), Colors.orange);
      expect(overdueVehicle.getServiceStatusColor(), Colors.red);
      expect(unknownVehicle.getServiceStatusColor(), Colors.grey);
    });
    
    test('Vehicle formatting methods', () {
      final vehicle = Vehicle(
        id: 1,
        customerId: 1,
        brand: VehicleBrand.bmw,
        model: '5 Series',
        licensePlate: 'AB123CD',
        year: 2020,
        currentMileage: 25000,
        lastServiceMileage: 20000,
        lastServiceDate: DateTime(2023, 3, 15),
        nextServiceDate: DateTime(2023, 9, 15),
        isActive: true,
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 3, 15),
      );
      
      expect(vehicle.formattedLastServiceDate(), 'Mar 15, 2023');
      expect(vehicle.formattedNextServiceDate(), 'Sep 15, 2023');
      expect(vehicle.formattedMileage(), '25,000 km');
      expect(vehicle.formattedCreatedAt(), 'Jan 1, 2023');
      expect(vehicle.getBrandDisplayName(), 'BMW');
    });
    
    test('Vehicle brand helpers', () {
      final bmwVehicle = Vehicle(
        id: 1,
        customerId: 1,
        brand: VehicleBrand.bmw,
        model: '5 Series',
        licensePlate: 'AB123CD',
        year: 2020,
        currentMileage: 25000,
        lastServiceMileage: 20000,
        lastServiceDate: DateTime.now(),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final mercedesVehicle = Vehicle(
        id: 2,
        customerId: 1,
        brand: VehicleBrand.mercedes,
        model: 'E-Class',
        licensePlate: 'EF456GH',
        year: 2019,
        currentMileage: 30000,
        lastServiceMileage: 25000,
        lastServiceDate: DateTime.now(),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      expect(bmwVehicle.getBrandDisplayName(), 'BMW');
      expect(mercedesVehicle.getBrandDisplayName(), 'Mercedes');
      
      expect(bmwVehicle.getBrandColor(), const Color(0xFF0066B1)); // BMW Blue
      expect(mercedesVehicle.getBrandColor(), const Color(0xFF9A9A9A)); // Mercedes Silver
    });
    
    test('Vehicle brand from string', () {
      expect(VehicleBrand.values.firstWhere(
        (e) => e.name.toLowerCase() == 'bmw',
      ), VehicleBrand.bmw);
      
      expect(VehicleBrand.values.firstWhere(
        (e) => e.name.toLowerCase() == 'mercedes',
      ), VehicleBrand.mercedes);
      
      expect(VehicleBrand.values.firstWhere(
        (e) => e.name.toLowerCase() == 'volkswagen',
      ), VehicleBrand.volkswagen);
    });
  });
} 