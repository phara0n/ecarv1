import 'package:flutter_test/flutter_test.dart';
import 'package:admin_interface/services/vehicle_service.dart';
import 'package:admin_interface/models/vehicle.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'dart:convert';

// Create a mock Http client
class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('VehicleService Tests', () {
    late VehicleService vehicleService;
    late MockHttpClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockHttpClient();
      vehicleService = VehicleService(client: mockHttpClient);
      registerFallbackValue(Uri.parse('http://example.com'));
    });

    test('getVehicles returns a list of vehicles on success', () async {
      // Mock response data
      final mockVehiclesJson = [
        {
          'id': 1,
          'make': 'Toyota',
          'model': 'Camry',
          'year': 2020,
          'license_plate': 'ABC123',
          'vin': '1HGCM82633A123456',
          'color': 'White',
          'current_mileage': 25000,
          'last_service_date': '2023-01-15T00:00:00.000Z',
          'next_service_date': '2023-07-15T00:00:00.000Z',
          'customer_id': 1,
          'customer_name': 'John Doe',
          'status': 'active',
          'created_at': '2022-10-15T00:00:00.000Z',
          'updated_at': '2023-01-15T00:00:00.000Z'
        },
        {
          'id': 2,
          'make': 'Honda',
          'model': 'Civic',
          'year': 2019,
          'license_plate': 'XYZ789',
          'vin': 'JH2SC5701PM000123',
          'color': 'Blue',
          'current_mileage': 30000,
          'last_service_date': '2023-02-20T00:00:00.000Z',
          'next_service_date': '2023-08-20T00:00:00.000Z',
          'customer_id': 2,
          'customer_name': 'Jane Smith',
          'status': 'active',
          'created_at': '2022-09-10T00:00:00.000Z',
          'updated_at': '2023-02-20T00:00:00.000Z'
        }
      ];

      // Set up the mock HTTP client
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode({'vehicles': mockVehiclesJson, 'total': 2}),
                200,
              ));

      // Call the method being tested
      final result = await vehicleService.getVehicles();

      // Verify the API call was made correctly
      verify(() => mockHttpClient.get(
            Uri.parse('${VehicleService.baseUrl}/vehicles'),
            headers: any(named: 'headers'),
          )).called(1);

      // Check the result
      expect(result.length, 2);
      expect(result[0].id, 1);
      expect(result[0].make, 'Toyota');
      expect(result[0].model, 'Camry');
      expect(result[1].id, 2);
      expect(result[1].make, 'Honda');
      expect(result[1].model, 'Civic');
    });

    test('getVehicleById returns a vehicle on success', () async {
      // Mock response data
      final mockVehicleJson = {
        'id': 1,
        'make': 'Toyota',
        'model': 'Camry',
        'year': 2020,
        'license_plate': 'ABC123',
        'vin': '1HGCM82633A123456',
        'color': 'White',
        'current_mileage': 25000,
        'last_service_date': '2023-01-15T00:00:00.000Z',
        'next_service_date': '2023-07-15T00:00:00.000Z',
        'customer_id': 1,
        'customer_name': 'John Doe',
        'status': 'active',
        'created_at': '2022-10-15T00:00:00.000Z',
        'updated_at': '2023-01-15T00:00:00.000Z'
      };

      // Set up the mock HTTP client
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode({'vehicle': mockVehicleJson}),
                200,
              ));

      // Call the method being tested
      final result = await vehicleService.getVehicleById(1);

      // Verify the API call was made correctly
      verify(() => mockHttpClient.get(
            Uri.parse('${VehicleService.baseUrl}/vehicles/1'),
            headers: any(named: 'headers'),
          )).called(1);

      // Check the result
      expect(result.id, 1);
      expect(result.make, 'Toyota');
      expect(result.model, 'Camry');
      expect(result.licensePlate, 'ABC123');
    });

    test('createVehicle creates and returns a vehicle on success', () async {
      // Create a vehicle object to use in the test
      final vehicle = Vehicle(
        make: 'Toyota',
        model: 'Corolla',
        year: 2021,
        licensePlate: 'DEF456',
        vin: '5YJSA1DN5BFP00001',
        color: 'Silver',
        currentMileage: 10000,
        lastServiceDate: DateTime(2023, 1, 10),
        nextServiceDate: DateTime(2023, 7, 10),
        customerId: 3,
        status: 'active',
      );

      // Mock response data
      final mockResponseJson = {
        'id': 3,
        'make': 'Toyota',
        'model': 'Corolla',
        'year': 2021,
        'license_plate': 'DEF456',
        'vin': '5YJSA1DN5BFP00001',
        'color': 'Silver',
        'current_mileage': 10000,
        'last_service_date': '2023-01-10T00:00:00.000Z',
        'next_service_date': '2023-07-10T00:00:00.000Z',
        'customer_id': 3,
        'customer_name': 'Bob Johnson',
        'status': 'active',
        'created_at': '2023-03-15T00:00:00.000Z',
        'updated_at': '2023-03-15T00:00:00.000Z'
      };

      // Set up the mock HTTP client
      when(() => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
                jsonEncode({'vehicle': mockResponseJson}),
                201,
              ));

      // Call the method being tested
      final result = await vehicleService.createVehicle(vehicle);

      // Verify the API call was made correctly
      verify(() => mockHttpClient.post(
            Uri.parse('${VehicleService.baseUrl}/vehicles'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).called(1);

      // Check the result
      expect(result.id, 3);
      expect(result.make, 'Toyota');
      expect(result.model, 'Corolla');
      expect(result.licensePlate, 'DEF456');
      expect(result.customerId, 3);
    });

    test('updateVehicle updates and returns a vehicle on success', () async {
      // Create a vehicle object to use in the test
      final vehicle = Vehicle(
        id: 2,
        make: 'Honda',
        model: 'Civic',
        year: 2019,
        licensePlate: 'XYZ789',
        vin: 'JH2SC5701PM000123',
        color: 'Red', // Changed from Blue
        currentMileage: 32000, // Updated mileage
        lastServiceDate: DateTime(2023, 3, 15),
        nextServiceDate: DateTime(2023, 9, 15),
        customerId: 2,
        status: 'active',
      );

      // Mock response data
      final mockResponseJson = {
        'id': 2,
        'make': 'Honda',
        'model': 'Civic',
        'year': 2019,
        'license_plate': 'XYZ789',
        'vin': 'JH2SC5701PM000123',
        'color': 'Red',
        'current_mileage': 32000,
        'last_service_date': '2023-03-15T00:00:00.000Z',
        'next_service_date': '2023-09-15T00:00:00.000Z',
        'customer_id': 2,
        'customer_name': 'Jane Smith',
        'status': 'active',
        'created_at': '2022-09-10T00:00:00.000Z',
        'updated_at': '2023-03-15T00:00:00.000Z'
      };

      // Set up the mock HTTP client
      when(() => mockHttpClient.put(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
                jsonEncode({'vehicle': mockResponseJson}),
                200,
              ));

      // Call the method being tested
      final result = await vehicleService.updateVehicle(vehicle);

      // Verify the API call was made correctly
      verify(() => mockHttpClient.put(
            Uri.parse('${VehicleService.baseUrl}/vehicles/2'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).called(1);

      // Check the result
      expect(result.id, 2);
      expect(result.color, 'Red'); // Check the color was updated
      expect(result.currentMileage, 32000); // Check the mileage was updated
    });

    test('deleteVehicle returns true on success', () async {
      // Set up the mock HTTP client
      when(() => mockHttpClient.delete(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(
                '{"success": true}',
                200,
              ));

      // Call the method being tested
      final result = await vehicleService.deleteVehicle(1);

      // Verify the API call was made correctly
      verify(() => mockHttpClient.delete(
            Uri.parse('${VehicleService.baseUrl}/vehicles/1'),
            headers: any(named: 'headers'),
          )).called(1);

      // Check the result
      expect(result, true);
    });

    test('getVehicleStatistics returns statistics on success', () async {
      // Mock response data
      final mockStatsJson = {
        'total_vehicles': 100,
        'active_vehicles': 90,
        'inactive_vehicles': 10,
        'vehicles_due_service': 15,
        'vehicles_by_make': {
          'Toyota': 30,
          'Honda': 25,
          'BMW': 15,
          'Mercedes': 10,
          'Others': 20
        },
        'recent_services': [
          {
            'id': 1,
            'vehicle_id': 1,
            'make': 'Toyota',
            'model': 'Camry',
            'service_date': '2023-03-10T00:00:00.000Z',
            'description': 'Oil change'
          },
          {
            'id': 2,
            'vehicle_id': 2,
            'make': 'Honda',
            'model': 'Civic',
            'service_date': '2023-03-05T00:00:00.000Z',
            'description': 'Brake pad replacement'
          }
        ]
      };

      // Set up the mock HTTP client
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode({'statistics': mockStatsJson}),
                200,
              ));

      // Call the method being tested
      final result = await vehicleService.getVehicleStatistics();

      // Verify the API call was made correctly
      verify(() => mockHttpClient.get(
            Uri.parse('${VehicleService.baseUrl}/vehicles/statistics'),
            headers: any(named: 'headers'),
          )).called(1);

      // Check the result
      expect(result['total_vehicles'], 100);
      expect(result['active_vehicles'], 90);
      expect(result['vehicles_due_service'], 15);
      expect(result['vehicles_by_make']['Toyota'], 30);
      expect((result['recent_services'] as List).length, 2);
    });

    test('updateVehicleMileage updates mileage on success', () async {
      // Set up the mock HTTP client
      when(() => mockHttpClient.patch(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
                '{"success": true, "current_mileage": 35000}',
                200,
              ));

      // Call the method being tested
      final result = await vehicleService.updateVehicleMileage(1, 35000);

      // Verify the API call was made correctly
      verify(() => mockHttpClient.patch(
            Uri.parse('${VehicleService.baseUrl}/vehicles/1/mileage'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).called(1);

      // Check the result
      expect(result, true);
    });

    test('toggleVehicleStatus changes status on success', () async {
      // Set up the mock HTTP client
      when(() => mockHttpClient.patch(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
                '{"success": true, "status": "inactive"}',
                200,
              ));

      // Call the method being tested
      final result = await vehicleService.toggleVehicleStatus(1);

      // Verify the API call was made correctly
      verify(() => mockHttpClient.patch(
            Uri.parse('${VehicleService.baseUrl}/vehicles/1/toggle_status'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).called(1);

      // Check the result
      expect(result, true);
    });
  });
} 