class Invoice {
  final int id;
  final int repairId;
  final double amount;
  final String paymentStatus;
  final String? pdfDocument;
  final double? vatAmount;
  final String? paymentMethod;
  final double totalWithVat;
  
  Invoice({
    required this.id,
    required this.repairId,
    required this.amount,
    required this.paymentStatus,
    this.pdfDocument,
    this.vatAmount,
    this.paymentMethod,
    required this.totalWithVat,
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
    };
  }
  
  bool get isPaid => paymentStatus == 'paid';
  bool get isPending => paymentStatus == 'pending';
  bool get isPartiallyPaid => paymentStatus == 'partially_paid';
  bool get isCancelled => paymentStatus == 'cancelled';
} 