class Invoice {
  final int id;
  final int repairId;
  final double amount;
  final String paymentStatus;
  final String? pdfDocument;
  final double? vatAmount;
  final String? paymentMethod;
  final double totalWithVat;
  final DateTime date;
  final DateTime? dueDate;
  final DateTime? paymentDate;
  
  Invoice({
    required this.id,
    required this.repairId,
    required this.amount,
    required this.paymentStatus,
    this.pdfDocument,
    this.vatAmount,
    this.paymentMethod,
    required this.totalWithVat,
    required this.date,
    this.dueDate,
    this.paymentDate,
  });
  
  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      repairId: json['repair_id'],
      amount: json['amount'].toDouble(),
      paymentStatus: json['payment_status'],
      pdfDocument: json['pdf_document'],
      vatAmount: json['vat_amount']?.toDouble(),
      paymentMethod: json['payment_method'],
      totalWithVat: json['total_with_vat']?.toDouble() ?? json['amount'].toDouble(),
      date: json['date'] != null 
          ? DateTime.parse(json['date']) 
          : DateTime.now(),
      dueDate: json['due_date'] != null 
          ? DateTime.parse(json['due_date']) 
          : null,
      paymentDate: json['payment_date'] != null 
          ? DateTime.parse(json['payment_date']) 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'repair_id': repairId,
      'amount': amount,
      'payment_status': paymentStatus,
      'pdf_document': pdfDocument,
      'vat_amount': vatAmount,
      'payment_method': paymentMethod,
      'date': date.toIso8601String().split('T').first,
      'due_date': dueDate?.toIso8601String().split('T').first,
      'payment_date': paymentDate?.toIso8601String().split('T').first,
    };
  }
  
  bool get isPaid => paymentStatus == 'paid';
  bool get isPending => paymentStatus == 'pending';
  bool get isPartiallyPaid => paymentStatus == 'partially_paid';
  bool get isCancelled => paymentStatus == 'cancelled';
} 