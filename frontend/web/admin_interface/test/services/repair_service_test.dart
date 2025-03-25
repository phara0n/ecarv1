import 'package:flutter_test/flutter_test.dart';
import 'package:admin_interface/services/repair_service.dart';
import 'package:admin_interface/models/repair.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'dart:convert';

// Create a mock Http client
class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('RepairService Tests', () {
    late RepairService repairService;
    late MockHttpClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockHttpClient();
      repairService = RepairService(client: mockHttpClient);
      registerFallbackValue(Uri.parse('http://example.com'));
    });

    test('getRepairs returns a list of repairs on success', () async {
      // Mock response data
      final mockRepairsJson = [
        {
          'id': 1,
          'vehicle_id': 1,
          'customer_id': 1,
          'customer_name': 'John Doe',
          'vehicle_info': 'Toyota Camry (ABC123)',
          'description': 'Oil change and filter replacement',
          'status': 'completed',
          'start_date': '2023-02-15T00:00:00.000Z',
          'completion_date': '2023-02-15T00:00:00.000Z',
          'total_cost': 85.50,
          'mechanic_name': 'Mike Johnson',
          'parts_used': 'Oil filter, Engine oil',
          'diagnostic_notes': 'No issues found',
          'is_paid': true,
          'created_at': '2023-02-14T00:00:00.000Z',
          'updated_at': '2023-02-15T00:00:00.000Z'
        },
        {
          'id': 2,
          'vehicle_id': 2,
          'customer_id': 2,
          'customer_name': 'Jane Smith',
          'vehicle_info': 'Honda Civic (XYZ789)',
          'description': 'Brake pad replacement',
          'status': 'in_progress',
          'start_date': '2023-03-10T00:00:00.000Z',
          'completion_date': null,
          'total_cost': 220.75,
          'mechanic_name': 'Ahmed Ali',
          'parts_used': 'Front brake pads, Brake fluid',
          'diagnostic_notes': 'Front brake pads worn',
          'is_paid': false,
          'created_at': '2023-03-09T00:00:00.000Z',
          'updated_at': '2023-03-10T00:00:00.000Z'
        }
      ];

      // Set up the mock HTTP client
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode({'repairs': mockRepairsJson, 'total': 2}),
                200,
              ));

      // Call the method being tested
      final result = await repairService.getRepairs();

      // Verify the API call was made correctly
      verify(() => mockHttpClient.get(
            Uri.parse('${RepairService.baseUrl}/repairs'),
            headers: any(named: 'headers'),
          )).called(1);

      // Check the result
      expect(result.length, 2);
      expect(result[0].id, 1);
      expect(result[0].vehicleId, 1);
      expect(result[0].description, 'Oil change and filter replacement');
      expect(result[0].status, 'completed');
      expect(result[0].isPaid, true);
      expect(result[1].id, 2);
      expect(result[1].vehicleId, 2);
      expect(result[1].description, 'Brake pad replacement');
      expect(result[1].status, 'in_progress');
      expect(result[1].isPaid, false);
    });

    test('getRepairById returns a repair on success', () async {
      // Mock response data
      final mockRepairJson = {
        'id': 1,
        'vehicle_id': 1,
        'customer_id': 1,
        'customer_name': 'John Doe',
        'vehicle_info': 'Toyota Camry (ABC123)',
        'description': 'Oil change and filter replacement',
        'status': 'completed',
        'start_date': '2023-02-15T00:00:00.000Z',
        'completion_date': '2023-02-15T00:00:00.000Z',
        'total_cost': 85.50,
        'mechanic_name': 'Mike Johnson',
        'parts_used': 'Oil filter, Engine oil',
        'diagnostic_notes': 'No issues found',
        'is_paid': true,
        'created_at': '2023-02-14T00:00:00.000Z',
        'updated_at': '2023-02-15T00:00:00.000Z'
      };

      // Set up the mock HTTP client
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode({'repair': mockRepairJson}),
                200,
              ));

      // Call the method being tested
      final result = await repairService.getRepairById(1);

      // Verify the API call was made correctly
      verify(() => mockHttpClient.get(
            Uri.parse('${RepairService.baseUrl}/repairs/1'),
            headers: any(named: 'headers'),
          )).called(1);

      // Check the result
      expect(result.id, 1);
      expect(result.vehicleId, 1);
      expect(result.customerId, 1);
      expect(result.customerName, 'John Doe');
      expect(result.description, 'Oil change and filter replacement');
      expect(result.totalCost, 85.50);
    });

    test('createRepair creates and returns a repair on success', () async {
      // Create a repair object to use in the test
      final repair = Repair(
        vehicleId: 3,
        customerId: 3,
        description: 'Transmission fluid change',
        status: 'scheduled',
        startDate: DateTime(2023, 3, 25),
        totalCost: 150.0,
        mechanicName: 'Carlos Rodriguez',
        partsUsed: 'Transmission fluid, filter',
        diagnosticNotes: 'Scheduled maintenance',
        isPaid: false,
      );

      // Mock response data
      final mockResponseJson = {
        'id': 3,
        'vehicle_id': 3,
        'customer_id': 3,
        'customer_name': 'Bob Johnson',
        'vehicle_info': 'BMW 3 Series (DEF456)',
        'description': 'Transmission fluid change',
        'status': 'scheduled',
        'start_date': '2023-03-25T00:00:00.000Z',
        'completion_date': null,
        'total_cost': 150.0,
        'mechanic_name': 'Carlos Rodriguez',
        'parts_used': 'Transmission fluid, filter',
        'diagnostic_notes': 'Scheduled maintenance',
        'is_paid': false,
        'created_at': '2023-03-15T00:00:00.000Z',
        'updated_at': '2023-03-15T00:00:00.000Z'
      };

      // Set up the mock HTTP client
      when(() => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
                jsonEncode({'repair': mockResponseJson}),
                201,
              ));

      // Call the method being tested
      final result = await repairService.createRepair(repair);

      // Verify the API call was made correctly
      verify(() => mockHttpClient.post(
            Uri.parse('${RepairService.baseUrl}/repairs'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).called(1);

      // Check the result
      expect(result.id, 3);
      expect(result.vehicleId, 3);
      expect(result.customerId, 3);
      expect(result.description, 'Transmission fluid change');
      expect(result.status, 'scheduled');
      expect(result.totalCost, 150.0);
    });

    test('updateRepair updates and returns a repair on success', () async {
      // Create a repair object to use in the test
      final repair = Repair(
        id: 2,
        vehicleId: 2,
        customerId: 2,
        description: 'Brake pad replacement and rotor inspection',
        status: 'completed',
        startDate: DateTime(2023, 3, 10),
        completionDate: DateTime(2023, 3, 12),
        totalCost: 250.75, // Changed from 220.75
        mechanicName: 'Ahmed Ali',
        partsUsed: 'Front brake pads, Brake fluid, Rotors',
        diagnosticNotes: 'Front brake pads worn, rotors in good condition',
        isPaid: true, // Changed from false
      );

      // Mock response data
      final mockResponseJson = {
        'id': 2,
        'vehicle_id': 2,
        'customer_id': 2,
        'customer_name': 'Jane Smith',
        'vehicle_info': 'Honda Civic (XYZ789)',
        'description': 'Brake pad replacement and rotor inspection',
        'status': 'completed',
        'start_date': '2023-03-10T00:00:00.000Z',
        'completion_date': '2023-03-12T00:00:00.000Z',
        'total_cost': 250.75,
        'mechanic_name': 'Ahmed Ali',
        'parts_used': 'Front brake pads, Brake fluid, Rotors',
        'diagnostic_notes': 'Front brake pads worn, rotors in good condition',
        'is_paid': true,
        'created_at': '2023-03-09T00:00:00.000Z',
        'updated_at': '2023-03-12T00:00:00.000Z'
      };

      // Set up the mock HTTP client
      when(() => mockHttpClient.put(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
                jsonEncode({'repair': mockResponseJson}),
                200,
              ));

      // Call the method being tested
      final result = await repairService.updateRepair(repair);

      // Verify the API call was made correctly
      verify(() => mockHttpClient.put(
            Uri.parse('${RepairService.baseUrl}/repairs/2'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).called(1);

      // Check the result
      expect(result.id, 2);
      expect(result.description, 'Brake pad replacement and rotor inspection');
      expect(result.status, 'completed');
      expect(result.totalCost, 250.75);
      expect(result.isPaid, true);
      expect(result.completionDate, isNotNull);
    });

    test('deleteRepair returns true on success', () async {
      // Set up the mock HTTP client
      when(() => mockHttpClient.delete(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(
                '{"success": true}',
                200,
              ));

      // Call the method being tested
      final result = await repairService.deleteRepair(1);

      // Verify the API call was made correctly
      verify(() => mockHttpClient.delete(
            Uri.parse('${RepairService.baseUrl}/repairs/1'),
            headers: any(named: 'headers'),
          )).called(1);

      // Check the result
      expect(result, true);
    });

    test('getRepairStatistics returns statistics on success', () async {
      // Mock response data
      final mockStatsJson = {
        'total_repairs': 150,
        'completed_repairs': 120,
        'in_progress_repairs': 20,
        'scheduled_repairs': 10,
        'total_revenue': 25000.50,
        'average_repair_cost': 166.67,
        'repairs_by_status': {
          'completed': 120,
          'in_progress': 20,
          'scheduled': 10,
          'cancelled': 0
        },
        'recent_repairs': [
          {
            'id': 1,
            'vehicle_info': 'Toyota Camry (ABC123)',
            'description': 'Oil change',
            'status': 'completed',
            'completion_date': '2023-03-15T00:00:00.000Z',
            'total_cost': 85.50
          },
          {
            'id': 2,
            'vehicle_info': 'Honda Civic (XYZ789)',
            'description': 'Brake pad replacement',
            'status': 'completed',
            'completion_date': '2023-03-12T00:00:00.000Z',
            'total_cost': 250.75
          }
        ],
        'repairs_by_month': {
          'Jan': 25,
          'Feb': 28,
          'Mar': 30,
          'Apr': 27
        }
      };

      // Set up the mock HTTP client
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode({'statistics': mockStatsJson}),
                200,
              ));

      // Call the method being tested
      final result = await repairService.getRepairStatistics();

      // Verify the API call was made correctly
      verify(() => mockHttpClient.get(
            Uri.parse('${RepairService.baseUrl}/repairs/statistics'),
            headers: any(named: 'headers'),
          )).called(1);

      // Check the result
      expect(result['total_repairs'], 150);
      expect(result['completed_repairs'], 120);
      expect(result['in_progress_repairs'], 20);
      expect(result['total_revenue'], 25000.50);
      expect(result['repairs_by_status']['completed'], 120);
      expect((result['recent_repairs'] as List).length, 2);
      expect(result['repairs_by_month']['Mar'], 30);
    });

    test('updateRepairStatus updates status on success', () async {
      // Set up the mock HTTP client
      when(() => mockHttpClient.patch(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
                '{"success": true, "status": "completed"}',
                200,
              ));

      // Call the method being tested
      final result = await repairService.updateRepairStatus(1, 'completed');

      // Verify the API call was made correctly
      verify(() => mockHttpClient.patch(
            Uri.parse('${RepairService.baseUrl}/repairs/1/status'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).called(1);

      // Check the result
      expect(result, true);
    });

    test('updateRepairPaymentStatus updates payment status on success', () async {
      // Set up the mock HTTP client
      when(() => mockHttpClient.patch(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
                '{"success": true, "is_paid": true}',
                200,
              ));

      // Call the method being tested
      final result = await repairService.updateRepairPaymentStatus(1, true);

      // Verify the API call was made correctly
      verify(() => mockHttpClient.patch(
            Uri.parse('${RepairService.baseUrl}/repairs/1/payment'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).called(1);

      // Check the result
      expect(result, true);
    });

    test('getVehicleRepairs returns repairs for a vehicle on success', () async {
      // Mock response data
      final mockRepairsJson = [
        {
          'id': 1,
          'description': 'Oil change',
          'status': 'completed',
          'start_date': '2023-01-15T00:00:00.000Z',
          'completion_date': '2023-01-15T00:00:00.000Z',
          'total_cost': 85.50
        },
        {
          'id': 3,
          'description': 'Tire rotation',
          'status': 'completed',
          'start_date': '2023-03-01T00:00:00.000Z',
          'completion_date': '2023-03-01T00:00:00.000Z',
          'total_cost': 60.00
        }
      ];

      // Set up the mock HTTP client
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode({'repairs': mockRepairsJson}),
                200,
              ));

      // Call the method being tested
      final result = await repairService.getVehicleRepairs(1);

      // Verify the API call was made correctly
      verify(() => mockHttpClient.get(
            Uri.parse('${RepairService.baseUrl}/vehicles/1/repairs'),
            headers: any(named: 'headers'),
          )).called(1);

      // Check the result
      expect(result.length, 2);
      expect(result[0]['id'], 1);
      expect(result[0]['description'], 'Oil change');
      expect(result[1]['id'], 3);
      expect(result[1]['description'], 'Tire rotation');
    });
  });
} 