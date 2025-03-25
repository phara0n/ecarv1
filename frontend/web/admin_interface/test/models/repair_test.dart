import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:admin_interface/models/repair.dart';

void main() {
  group('Repair Model Tests', () {
    test('Repair fromJson and toJson', () {
      final dateTime = DateTime(2023, 3, 15);
      final completionDate = DateTime(2023, 3, 20);
      
      final Map<String, dynamic> json = {
        'id': 1,
        'vehicle_id': 2,
        'customer_id': 3,
        'customer_name': 'John Doe',
        'vehicle_info': 'BMW 5 Series (AB123CD)',
        'description': 'Regular maintenance and oil change',
        'status': 'completed',
        'start_date': '2023-03-15T00:00:00.000Z',
        'completion_date': '2023-03-20T00:00:00.000Z',
        'total_cost': 350.75,
        'mechanic_name': 'Ahmed Ben Ali',
        'parts_used': 'Oil filter, Air filter, Engine oil',
        'diagnostic_notes': 'Slight brake wear detected',
        'is_paid': true,
        'created_at': '2023-03-15T00:00:00.000Z',
        'updated_at': '2023-03-20T00:00:00.000Z',
      };
      
      final repair = Repair.fromJson(json);
      
      expect(repair.id, 1);
      expect(repair.vehicleId, 2);
      expect(repair.customerId, 3);
      expect(repair.customerName, 'John Doe');
      expect(repair.vehicleInfo, 'BMW 5 Series (AB123CD)');
      expect(repair.description, 'Regular maintenance and oil change');
      expect(repair.status, 'completed');
      expect(repair.startDate.year, dateTime.year);
      expect(repair.startDate.month, dateTime.month);
      expect(repair.startDate.day, dateTime.day);
      expect(repair.completionDate!.year, completionDate.year);
      expect(repair.completionDate!.month, completionDate.month);
      expect(repair.completionDate!.day, completionDate.day);
      expect(repair.totalCost, 350.75);
      expect(repair.mechanicName, 'Ahmed Ben Ali');
      expect(repair.partsUsed, 'Oil filter, Air filter, Engine oil');
      expect(repair.diagnosticNotes, 'Slight brake wear detected');
      expect(repair.isPaid, true);
      
      final jsonResult = repair.toJson();
      
      expect(jsonResult['vehicle_id'], 2);
      expect(jsonResult['customer_id'], 3);
      expect(jsonResult['description'], 'Regular maintenance and oil change');
      expect(jsonResult['status'], 'completed');
      expect(jsonResult['total_cost'], 350.75);
      expect(jsonResult['mechanic_name'], 'Ahmed Ben Ali');
      expect(jsonResult['parts_used'], 'Oil filter, Air filter, Engine oil');
      expect(jsonResult['diagnostic_notes'], 'Slight brake wear detected');
      expect(jsonResult['is_paid'], true);
    });
    
    test('Repair status helpers', () {
      final scheduledRepair = Repair(
        id: 1,
        vehicleId: 1,
        customerId: 1,
        description: 'Oil change',
        status: 'scheduled',
        startDate: DateTime.now().add(const Duration(days: 7)),
        created_at: DateTime.now(),
        updated_at: DateTime.now(),
      );
      
      final inProgressRepair = Repair(
        id: 2,
        vehicleId: 2,
        customerId: 1,
        description: 'Brake replacement',
        status: 'in_progress',
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        created_at: DateTime.now(),
        updated_at: DateTime.now(),
      );
      
      final completedRepair = Repair(
        id: 3,
        vehicleId: 3,
        customerId: 2,
        description: 'Engine tune-up',
        status: 'completed',
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        completionDate: DateTime.now().subtract(const Duration(days: 1)),
        created_at: DateTime.now(),
        updated_at: DateTime.now(),
      );
      
      final cancelledRepair = Repair(
        id: 4,
        vehicleId: 4,
        customerId: 2,
        description: 'Transmission repair',
        status: 'cancelled',
        startDate: DateTime.now().subtract(const Duration(days: 3)),
        created_at: DateTime.now(),
        updated_at: DateTime.now(),
      );
      
      // Test status helpers
      expect(scheduledRepair.isScheduled, true);
      expect(scheduledRepair.isInProgress, false);
      expect(scheduledRepair.isCompleted, false);
      expect(scheduledRepair.isCancelled, false);
      
      expect(inProgressRepair.isScheduled, false);
      expect(inProgressRepair.isInProgress, true);
      expect(inProgressRepair.isCompleted, false);
      expect(inProgressRepair.isCancelled, false);
      
      expect(completedRepair.isScheduled, false);
      expect(completedRepair.isInProgress, false);
      expect(completedRepair.isCompleted, true);
      expect(completedRepair.isCancelled, false);
      
      expect(cancelledRepair.isScheduled, false);
      expect(cancelledRepair.isInProgress, false);
      expect(cancelledRepair.isCompleted, false);
      expect(cancelledRepair.isCancelled, true);
    });
    
    test('Repair status display helpers', () {
      final scheduledRepair = Repair(
        id: 1,
        vehicleId: 1,
        customerId: 1,
        description: 'Oil change',
        status: 'scheduled',
        startDate: DateTime.now().add(const Duration(days: 7)),
        created_at: DateTime.now(),
        updated_at: DateTime.now(),
      );
      
      // Test status text and color
      expect(Repair.getStatusText('scheduled'), 'Scheduled');
      expect(Repair.getStatusText('in_progress'), 'In Progress');
      expect(Repair.getStatusText('completed'), 'Completed');
      expect(Repair.getStatusText('cancelled'), 'Cancelled');
      
      expect(Repair.getStatusColor('scheduled'), Colors.blue);
      expect(Repair.getStatusColor('in_progress'), Colors.orange);
      expect(Repair.getStatusColor('completed'), Colors.green);
      expect(Repair.getStatusColor('cancelled'), Colors.red);
      
      // Test instance methods
      expect(scheduledRepair.getStatusText(), 'Scheduled');
      expect(scheduledRepair.getStatusColor(), Colors.blue);
    });
    
    test('Repair formatting methods', () {
      final repair = Repair(
        id: 1,
        vehicleId: 1,
        customerId: 1,
        description: 'Oil change',
        status: 'completed',
        startDate: DateTime(2023, 3, 15),
        completionDate: DateTime(2023, 3, 16),
        totalCost: 150.75,
        created_at: DateTime(2023, 3, 14),
        updated_at: DateTime(2023, 3, 16),
      );
      
      expect(repair.formattedStartDate(), 'Mar 15, 2023');
      expect(repair.formattedCompletionDate(), 'Mar 16, 2023');
      expect(repair.formattedTotalCost(), 'TD 150.75');
    });
  });
} 