import 'package:flutter_test/flutter_test.dart';
import 'package:ecar_garage/models/invoice.dart';
import 'package:ecar_garage/models/repair.dart';
import 'package:ecar_garage/models/customer.dart';
import 'package:ecar_garage/models/vehicle.dart';

void main() {
  group('Invoice Model', () {
    final vehicle = Vehicle(
      id: 1,
      brand: 'BMW',
      model: '3 Series',
      year: 2018,
      licensePlate: '123 TUN 4567',
      currentMileage: 50000,
    );
    
    final repair = Repair(
      id: 1,
      description: 'Oil change and brake inspection',
      status: 'completed',
      startDate: '2023-05-15',
      completionDate: '2023-05-16',
      vehicle: vehicle,
      technicianName: 'Ahmed Ben Ali',
    );
    
    final customer = Customer(
      id: 1,
      firstName: 'Mohammed',
      lastName: 'Khadhraoui',
      email: 'mohammed@example.com',
      phone: '216 98 765 432',
      address: 'Tunis, Tunisia',
    );
    
    test('should create from JSON correctly', () {
      final json = {
        'id': 1,
        'invoiceNumber': 'ECAR/2023/050001',
        'amount': 150.00,
        'issueDate': '2023-05-16',
        'dueDate': '2023-06-15',
        'paymentStatus': 'unpaid',
        'repair': {
          'id': 1,
          'description': 'Oil change and brake inspection',
          'status': 'completed',
          'startDate': '2023-05-15',
          'completionDate': '2023-05-16',
          'technicianName': 'Ahmed Ben Ali',
          'vehicle': {
            'id': 1,
            'brand': 'BMW',
            'model': '3 Series',
            'year': 2018,
            'licensePlate': '123 TUN 4567',
            'currentMileage': 50000,
          }
        },
        'customer': {
          'id': 1,
          'firstName': 'Mohammed',
          'lastName': 'Khadhraoui',
          'email': 'mohammed@example.com',
          'phone': '216 98 765 432',
          'address': 'Tunis, Tunisia',
        }
      };
      
      final invoice = Invoice.fromJson(json);
      
      expect(invoice.id, 1);
      expect(invoice.invoiceNumber, 'ECAR/2023/050001');
      expect(invoice.amount, 150.00);
      expect(invoice.issueDate, '2023-05-16');
      expect(invoice.dueDate, '2023-06-15');
      expect(invoice.paymentStatus, 'unpaid');
      expect(invoice.repair.id, 1);
      expect(invoice.customer.id, 1);
    });
    
    test('should convert to JSON correctly', () {
      final invoice = Invoice(
        id: 1,
        invoiceNumber: 'ECAR/2023/050001',
        amount: 150.00,
        issueDate: '2023-05-16',
        dueDate: '2023-06-15',
        paymentStatus: 'unpaid',
        repair: repair,
        customer: customer,
      );
      
      final json = invoice.toJson();
      
      expect(json['id'], 1);
      expect(json['invoiceNumber'], 'ECAR/2023/050001');
      expect(json['amount'], 150.00);
      expect(json['issueDate'], '2023-05-16');
      expect(json['dueDate'], '2023-06-15');
      expect(json['paymentStatus'], 'unpaid');
      expect(json['repair'], isNotNull);
      expect(json['customer'], isNotNull);
    });
    
    test('should calculate remaining amount correctly', () {
      // Unpaid invoice
      final unpaidInvoice = Invoice(
        id: 1,
        invoiceNumber: 'ECAR/2023/050001',
        amount: 150.00,
        issueDate: '2023-05-16',
        paymentStatus: 'unpaid',
        repair: repair,
        customer: customer,
      );
      
      expect(unpaidInvoice.remainingAmount, 150.00);
      
      // Partially paid invoice
      final partialInvoice = Invoice(
        id: 2,
        invoiceNumber: 'ECAR/2023/050002',
        amount: 150.00,
        issueDate: '2023-05-16',
        paymentStatus: 'partial',
        paidAmount: 75.00,
        repair: repair,
        customer: customer,
      );
      
      expect(partialInvoice.remainingAmount, 75.00);
      
      // Fully paid invoice
      final paidInvoice = Invoice(
        id: 3,
        invoiceNumber: 'ECAR/2023/050003',
        amount: 150.00,
        issueDate: '2023-05-16',
        paymentStatus: 'paid',
        paidAmount: 150.00,
        repair: repair,
        customer: customer,
      );
      
      expect(paidInvoice.remainingAmount, 0.0);
    });
    
    test('should format amounts correctly', () {
      final amount = 150.75;
      final formattedAmount = Invoice.formatAmount(amount);
      
      expect(formattedAmount, '150.75');
    });
    
    test('should have correct payment status helpers', () {
      final unpaidInvoice = Invoice(
        id: 1,
        invoiceNumber: 'ECAR/2023/050001',
        amount: 150.00,
        issueDate: '2023-05-16',
        paymentStatus: 'unpaid',
        repair: repair,
        customer: customer,
      );
      
      expect(unpaidInvoice.isUnpaid, true);
      expect(unpaidInvoice.isPaid, false);
      expect(unpaidInvoice.isPartiallyPaid, false);
      
      final partialInvoice = Invoice(
        id: 2,
        invoiceNumber: 'ECAR/2023/050002',
        amount: 150.00,
        issueDate: '2023-05-16',
        paymentStatus: 'partial',
        repair: repair,
        customer: customer,
      );
      
      expect(partialInvoice.isUnpaid, false);
      expect(partialInvoice.isPaid, false);
      expect(partialInvoice.isPartiallyPaid, true);
      
      final paidInvoice = Invoice(
        id: 3,
        invoiceNumber: 'ECAR/2023/050003',
        amount: 150.00,
        issueDate: '2023-05-16',
        paymentStatus: 'paid',
        repair: repair,
        customer: customer,
      );
      
      expect(paidInvoice.isUnpaid, false);
      expect(paidInvoice.isPaid, true);
      expect(paidInvoice.isPartiallyPaid, false);
    });
  });
} 