import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Invoice {
  final int id;
  final int repairId;
  final int vehicleId;
  final int customerId;
  final String? vehicleBrand;
  final String? vehicleModel;
  final String? customerName;
  final String invoiceNumber;
  final DateTime issueDate;
  final DateTime dueDate;
  final double subtotal;
  final double taxAmount;
  final double total;
  final String status;
  final String? pdfUrl;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Invoice({
    required this.id,
    required this.repairId,
    required this.vehicleId,
    required this.customerId,
    this.vehicleBrand,
    this.vehicleModel,
    this.customerName,
    required this.invoiceNumber,
    required this.issueDate,
    required this.dueDate,
    required this.subtotal,
    required this.taxAmount,
    required this.total,
    required this.status,
    this.pdfUrl,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] as int,
      repairId: json['repair_id'] as int,
      vehicleId: json['vehicle_id'] as int,
      customerId: json['customer_id'] as int,
      vehicleBrand: json['vehicle_brand'] as String?,
      vehicleModel: json['vehicle_model'] as String?,
      customerName: json['customer_name'] as String?,
      invoiceNumber: json['invoice_number'] as String,
      issueDate: DateTime.parse(json['issue_date'] as String),
      dueDate: DateTime.parse(json['due_date'] as String),
      subtotal: (json['subtotal'] as num).toDouble(),
      taxAmount: (json['tax_amount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      status: json['status'] as String,
      pdfUrl: json['pdf_url'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'repair_id': repairId,
      'vehicle_id': vehicleId,
      'customer_id': customerId,
      'invoice_number': invoiceNumber,
      'issue_date': DateFormat('yyyy-MM-dd').format(issueDate),
      'due_date': DateFormat('yyyy-MM-dd').format(dueDate),
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'total': total,
      'status': status,
      'notes': notes,
    };
  }

  // Get invoice status color
  static Color getStatusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  // Get user-friendly status name
  static String getStatusName(String status) {
    switch (status) {
      case 'paid':
        return 'Paid';
      case 'pending':
        return 'Pending';
      case 'overdue':
        return 'Overdue';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  // Get available status options for dropdown
  static List<String> getStatusOptions() {
    return ['paid', 'pending', 'overdue', 'cancelled'];
  }

  // Calculate if invoice is overdue
  bool isOverdue() {
    return status != 'paid' && 
           status != 'cancelled' && 
           DateTime.now().isAfter(dueDate);
  }

  // Calculate days remaining until due or days overdue
  int daysToDue() {
    final today = DateTime.now();
    return dueDate.difference(today).inDays;
  }
} 