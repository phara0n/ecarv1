import 'package:flutter_test/flutter_test.dart';
import 'package:admin_interface/services/customer_service.dart';
import 'package:admin_interface/models/customer.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'dart:convert';

// Create a mock Http client
class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('CustomerService Tests', () {
    late CustomerService customerService;
    late MockHttpClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockHttpClient();
      customerService = CustomerService(client: mockHttpClient);
      registerFallbackValue(Uri.parse('http://example.com'));
    });

    test('getCustomers returns a list of customers on success', () async {
      // Mock response data
      final mockCustomersJson = [
        {
          'id': 1,
          'name': 'John Doe',
          'email': 'john.doe@example.com',
          'phone': '+1234567890',
          'address': '123 Main St, Anytown, AN',
          'created_at': '2022-10-15T00:00:00.000Z',
          'updated_at': '2023-01-15T00:00:00.000Z',
          'total_vehicles': 2,
          'total_spent': 750.50,
          'status': 'active'
        },
        {
          'id': 2,
          'name': 'Jane Smith',
          'email': 'jane.smith@example.com',
          'phone': '+0987654321',
          'address': '456 Oak Ave, Sometown, ST',
          'created_at': '2022-11-20T00:00:00.000Z',
          'updated_at': '2023-02-25T00:00:00.000Z',
          'total_vehicles': 1,
          'total_spent': 350.25,
          'status': 'active'
        }
      ];

      // Set up the mock HTTP client
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode({'customers': mockCustomersJson, 'total': 2}),
                200,
              ));

      // Call the method being tested
      final result = await customerService.getCustomers();

      // Verify the API call was made correctly
      verify(() => mockHttpClient.get(
            Uri.parse('${CustomerService.baseUrl}/customers'),
            headers: any(named: 'headers'),
          )).called(1);

      // Check the result
      expect(result.length, 2);
      expect(result[0].id, 1);
      expect(result[0].name, 'John Doe');
      expect(result[0].email, 'john.doe@example.com');
      expect(result[1].id, 2);
      expect(result[1].name, 'Jane Smith');
      expect(result[1].totalVehicles, 1);
    });

    test('getCustomerById returns a customer on success', () async {
      // Mock response data
      final mockCustomerJson = {
        'id': 1,
        'name': 'John Doe',
        'email': 'john.doe@example.com',
        'phone': '+1234567890',
        'address': '123 Main St, Anytown, AN',
        'created_at': '2022-10-15T00:00:00.000Z',
        'updated_at': '2023-01-15T00:00:00.000Z',
        'total_vehicles': 2,
        'total_spent': 750.50,
        'status': 'active'
      };

      // Set up the mock HTTP client
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode({'customer': mockCustomerJson}),
                200,
              ));

      // Call the method being tested
      final result = await customerService.getCustomerById(1);

      // Verify the API call was made correctly
      verify(() => mockHttpClient.get(
            Uri.parse('${CustomerService.baseUrl}/customers/1'),
            headers: any(named: 'headers'),
          )).called(1);

      // Check the result
      expect(result.id, 1);
      expect(result.name, 'John Doe');
      expect(result.email, 'john.doe@example.com');
      expect(result.phone, '+1234567890');
    });

    test('createCustomer creates and returns a customer on success', () async {
      // Create a customer object to use in the test
      final customer = Customer(
        name: 'Bob Johnson',
        email: 'bob.johnson@example.com',
        phone: '+1122334455',
        address: '789 Elm St, Newtown, NT',
        status: 'active',
      );

      // Mock response data
      final mockResponseJson = {
        'id': 3,
        'name': 'Bob Johnson',
        'email': 'bob.johnson@example.com',
        'phone': '+1122334455',
        'address': '789 Elm St, Newtown, NT',
        'created_at': '2023-03-15T00:00:00.000Z',
        'updated_at': '2023-03-15T00:00:00.000Z',
        'total_vehicles': 0,
        'total_spent': 0.0,
        'status': 'active'
      };

      // Set up the mock HTTP client
      when(() => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
                jsonEncode({'customer': mockResponseJson}),
                201,
              ));

      // Call the method being tested
      final result = await customerService.createCustomer(customer);

      // Verify the API call was made correctly
      verify(() => mockHttpClient.post(
            Uri.parse('${CustomerService.baseUrl}/customers'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).called(1);

      // Check the result
      expect(result.id, 3);
      expect(result.name, 'Bob Johnson');
      expect(result.email, 'bob.johnson@example.com');
      expect(result.totalVehicles, 0);
    });

    test('updateCustomer updates and returns a customer on success', () async {
      // Create a customer object to use in the test
      final customer = Customer(
        id: 2,
        name: 'Jane Smith',
        email: 'jane.smith@example.com',
        phone: '+9876543210', // Updated phone
        address: '456 Oak Ave, Sometown, ST',
        status: 'active',
      );

      // Mock response data
      final mockResponseJson = {
        'id': 2,
        'name': 'Jane Smith',
        'email': 'jane.smith@example.com',
        'phone': '+9876543210',
        'address': '456 Oak Ave, Sometown, ST',
        'created_at': '2022-11-20T00:00:00.000Z',
        'updated_at': '2023-03-15T00:00:00.000Z',
        'total_vehicles': 1,
        'total_spent': 350.25,
        'status': 'active'
      };

      // Set up the mock HTTP client
      when(() => mockHttpClient.put(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
                jsonEncode({'customer': mockResponseJson}),
                200,
              ));

      // Call the method being tested
      final result = await customerService.updateCustomer(customer);

      // Verify the API call was made correctly
      verify(() => mockHttpClient.put(
            Uri.parse('${CustomerService.baseUrl}/customers/2'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).called(1);

      // Check the result
      expect(result.id, 2);
      expect(result.phone, '+9876543210'); // Check the phone was updated
    });

    test('deleteCustomer returns true on success', () async {
      // Set up the mock HTTP client
      when(() => mockHttpClient.delete(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(
                '{"success": true}',
                200,
              ));

      // Call the method being tested
      final result = await customerService.deleteCustomer(1);

      // Verify the API call was made correctly
      verify(() => mockHttpClient.delete(
            Uri.parse('${CustomerService.baseUrl}/customers/1'),
            headers: any(named: 'headers'),
          )).called(1);

      // Check the result
      expect(result, true);
    });

    test('getCustomerStatistics returns statistics on success', () async {
      // Mock response data
      final mockStatsJson = {
        'total_customers': 250,
        'active_customers': 230,
        'inactive_customers': 20,
        'top_customers': [
          {
            'id': 1,
            'name': 'John Doe',
            'total_spent': 1500.75
          },
          {
            'id': 3,
            'name': 'Alice Walker',
            'total_spent': 1250.50
          }
        ],
        'new_customers_this_month': 15,
        'customer_growth': {
          'Jan': 20,
          'Feb': 15,
          'Mar': 25,
          'Apr': 18
        }
      };

      // Set up the mock HTTP client
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode({'statistics': mockStatsJson}),
                200,
              ));

      // Call the method being tested
      final result = await customerService.getCustomerStatistics();

      // Verify the API call was made correctly
      verify(() => mockHttpClient.get(
            Uri.parse('${CustomerService.baseUrl}/customers/statistics'),
            headers: any(named: 'headers'),
          )).called(1);

      // Check the result
      expect(result['total_customers'], 250);
      expect(result['active_customers'], 230);
      expect(result['new_customers_this_month'], 15);
      expect((result['top_customers'] as List).length, 2);
      expect((result['customer_growth'] as Map)['Jan'], 20);
    });

    test('toggleCustomerStatus changes status on success', () async {
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
      final result = await customerService.toggleCustomerStatus(1);

      // Verify the API call was made correctly
      verify(() => mockHttpClient.patch(
            Uri.parse('${CustomerService.baseUrl}/customers/1/toggle_status'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).called(1);

      // Check the result
      expect(result, true);
    });

    test('getCustomerVehicles returns a list of vehicles on success', () async {
      // Mock response data
      final mockVehiclesJson = [
        {
          'id': 1,
          'make': 'Toyota',
          'model': 'Camry',
          'year': 2020,
          'license_plate': 'ABC123',
          'status': 'active'
        },
        {
          'id': 2,
          'make': 'Honda',
          'model': 'Civic',
          'year': 2019,
          'license_plate': 'XYZ789',
          'status': 'active'
        }
      ];

      // Set up the mock HTTP client
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode({'vehicles': mockVehiclesJson}),
                200,
              ));

      // Call the method being tested
      final result = await customerService.getCustomerVehicles(1);

      // Verify the API call was made correctly
      verify(() => mockHttpClient.get(
            Uri.parse('${CustomerService.baseUrl}/customers/1/vehicles'),
            headers: any(named: 'headers'),
          )).called(1);

      // Check the result
      expect(result.length, 2);
      expect(result[0]['id'], 1);
      expect(result[0]['make'], 'Toyota');
      expect(result[1]['id'], 2);
      expect(result[1]['make'], 'Honda');
    });

    test('getCustomerRepairs returns a list of repairs on success', () async {
      // Mock response data
      final mockRepairsJson = [
        {
          'id': 1,
          'description': 'Oil change',
          'status': 'completed',
          'start_date': '2023-01-15T00:00:00.000Z',
          'total_cost': 50.75
        },
        {
          'id': 2,
          'description': 'Brake pad replacement',
          'status': 'completed',
          'start_date': '2023-02-20T00:00:00.000Z',
          'total_cost': 150.25
        }
      ];

      // Set up the mock HTTP client
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(
                jsonEncode({'repairs': mockRepairsJson}),
                200,
              ));

      // Call the method being tested
      final result = await customerService.getCustomerRepairs(1);

      // Verify the API call was made correctly
      verify(() => mockHttpClient.get(
            Uri.parse('${CustomerService.baseUrl}/customers/1/repairs'),
            headers: any(named: 'headers'),
          )).called(1);

      // Check the result
      expect(result.length, 2);
      expect(result[0]['id'], 1);
      expect(result[0]['description'], 'Oil change');
      expect(result[1]['id'], 2);
      expect(result[1]['description'], 'Brake pad replacement');
    });
  });
} 