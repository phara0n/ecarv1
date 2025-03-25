import 'package:json_annotation/json_annotation.dart';
import 'repair.dart';
import 'customer.dart';

part 'invoice.g.dart';

@JsonSerializable(explicitToJson: true)
class Invoice {
  final int id;
  final String invoiceNumber;
  final double amount;
  final double taxAmount;  // VAT amount (19% in Tunisia)
  final double totalAmount;
  final String issueDate;
  final String? dueDate;
  final String paymentStatus;  // 'unpaid', 'partial', 'paid'
  final String? paymentMethod;  // 'cash', 'credit_card', 'bank_transfer'
  final double? paidAmount;
  final String? paymentDate;
  final String? pdfUrl;
  
  // Tunisian fiscal information
  final String? fiscalId;
  final String? commercialRegistry;
  
  // Related entities
  final Repair repair;
  final Customer customer;
  
  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.amount,
    required this.taxAmount,
    required this.totalAmount,
    required this.issueDate,
    this.dueDate,
    required this.paymentStatus,
    this.paymentMethod,
    this.paidAmount,
    this.paymentDate,
    this.pdfUrl,
    this.fiscalId,
    this.commercialRegistry,
    required this.repair,
    required this.customer,
  });
  
  factory Invoice.fromJson(Map<String, dynamic> json) => _$InvoiceFromJson(json);
  Map<String, dynamic> toJson() => _$InvoiceToJson(this);
  
  // Helper methods
  bool get isPaid => paymentStatus == 'paid';
  bool get isPartiallyPaid => paymentStatus == 'partial';
  bool get isUnpaid => paymentStatus == 'unpaid';
  
  // Calculate remaining amount for partially paid invoices
  double get remainingAmount {
    if (isPaid) return 0;
    if (isUnpaid) return totalAmount;
    return totalAmount - (paidAmount ?? 0);
  }
  
  // Helper to calculate Tunisian VAT (19%)
  static double calculateVAT(double amount) {
    return amount * 0.19;
  }
  
  // Helper to format number with 3 decimals (Tunisian standard)
  static String formatAmount(double amount) {
    return amount.toStringAsFixed(3);
  }
} 