import 'package:flutter_test/flutter_test.dart';
import 'package:ecar_app/models/customer.dart';
import 'package:ecar_app/models/repair.dart';
import 'package:ecar_app/models/invoice.dart';

void main() {
  group('Customer Model Tests', () {
    test('Customer fromJson and toJson', () {
      final Map<String, dynamic> json = {
        'id': 1,
        'name': 'John Doe',
        'email': 'john@example.com',
        'phone': '+216 29 123 456',
        'address': '15 Rue de Carthage, Tunis',
      };
      
      final customer = Customer.fromJson(json);
      
      expect(customer.id, 1);
      expect(customer.name, 'John Doe');
      expect(customer.email, 'john@example.com');
      expect(customer.phone, '+216 29 123 456');
      expect(customer.address, '15 Rue de Carthage, Tunis');
      
      final jsonResult = customer.toJson();
      
      expect(jsonResult['id'], 1);
      expect(jsonResult['name'], 'John Doe');
      expect(jsonResult['email'], 'john@example.com');
      expect(jsonResult['phone'], '+216 29 123 456');
      expect(jsonResult['address'], '15 Rue de Carthage, Tunis');
    });
  });
  
  group('Repair Model Tests', () {
    test('Repair fromJson and toJson', () {
      final now = DateTime.now();
      final nowString = now.toIso8601String().split('T').first;
      final futureDate = DateTime.now().add(Duration(days: 180));
      final futureDateString = futureDate.toIso8601String().split('T').first;
      
      final Map<String, dynamic> json = {
        'id': 1,
        'vehicle_id': 2,
        'description': 'Oil change',
        'start_date': nowString,
        'status': 'completed',
        'date': nowString,
        'notes': 'Customer requested synthetic oil',
        'next_service_due_date': futureDateString,
        'next_service_description': 'Major service',
      };
      
      final repair = Repair.fromJson(json);
      
      expect(repair.id, 1);
      expect(repair.vehicleId, 2);
      expect(repair.description, 'Oil change');
      expect(repair.status, 'completed');
      expect(repair.date.year, now.year);
      expect(repair.date.month, now.month);
      expect(repair.date.day, now.day);
      expect(repair.notes, 'Customer requested synthetic oil');
      expect(repair.nextServiceDueDate!.year, futureDate.year);
      expect(repair.nextServiceDueDate!.month, futureDate.month);
      expect(repair.nextServiceDueDate!.day, futureDate.day);
      expect(repair.nextServiceDescription, 'Major service');
      
      final jsonResult = repair.toJson();
      
      expect(jsonResult['id'], 1);
      expect(jsonResult['vehicle_id'], 2);
      expect(jsonResult['description'], 'Oil change');
      expect(jsonResult['status'], 'completed');
      expect(jsonResult['date'], nowString);
      expect(jsonResult['notes'], 'Customer requested synthetic oil');
      expect(jsonResult['next_service_due_date'], futureDateString);
      expect(jsonResult['next_service_description'], 'Major service');
    });
    
    test('Repair status helper methods', () {
      final repair = Repair(
        id: 1,
        vehicleId: 1,
        description: 'Test',
        startDate: DateTime.now(),
        status: 'completed',
        date: DateTime.now(),
      );
      
      expect(repair.isCompleted, true);
      expect(repair.isInProgress, false);
      expect(repair.isScheduled, false);
      expect(repair.isCancelled, false);
    });
  });
  
  group('Invoice Model Tests', () {
    test('Invoice fromJson and toJson', () {
      final now = DateTime.now();
      final nowString = now.toIso8601String().split('T').first;
      final dueDate = DateTime.now().add(Duration(days: 30));
      final dueDateString = dueDate.toIso8601String().split('T').first;
      
      final Map<String, dynamic> json = {
        'id': 1,
        'repair_id': 2,
        'amount': 150.00,
        'payment_status': 'unpaid',
        'pdf_document': 'invoice_1.pdf',
        'payment_method': null,
        'date': nowString,
        'due_date': dueDateString,
      };
      
      final invoice = Invoice.fromJson(json);
      
      expect(invoice.id, 1);
      expect(invoice.repairId, 2);
      expect(invoice.amount, 150.00);
      expect(invoice.paymentStatus, 'unpaid');
      expect(invoice.pdfDocument, 'invoice_1.pdf');
      expect(invoice.paymentMethod, null);
      expect(invoice.date.year, now.year);
      expect(invoice.date.month, now.month);
      expect(invoice.date.day, now.day);
      expect(invoice.dueDate!.year, dueDate.year);
      expect(invoice.dueDate!.month, dueDate.month);
      expect(invoice.dueDate!.day, dueDate.day);
      
      final jsonResult = invoice.toJson();
      
      expect(jsonResult['id'], 1);
      expect(jsonResult['repair_id'], 2);
      expect(jsonResult['amount'], 150.00);
      expect(jsonResult['payment_status'], 'unpaid');
      expect(jsonResult['pdf_document'], 'invoice_1.pdf');
      expect(jsonResult['payment_method'], null);
      expect(jsonResult['date'], nowString);
      expect(jsonResult['due_date'], dueDateString);
    });
    
    test('Invoice status helper methods', () {
      final invoice = Invoice(
        id: 1,
        repairId: 1,
        amount: 150.00,
        paymentStatus: 'paid',
        totalWithVat: 150.00,
        date: DateTime.now(),
      );
      
      expect(invoice.isPaid, true);
      expect(invoice.isPending, false);
      expect(invoice.isPartiallyPaid, false);
      expect(invoice.isCancelled, false);
    });
  });
} 