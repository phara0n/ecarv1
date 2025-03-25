class Repair {
  final int id;
  final int vehicleId;
  final String description;
  final DateTime startDate;
  final DateTime? completionDate;
  final double? cost;
  final String status;
  final String? mechanic;
  final String? partsUsed;
  final double? laborHours;
  final DateTime? nextServiceEstimate;
  final int? totalDays;
  final DateTime date;
  final String? notes;
  final DateTime? nextServiceDueDate;
  final String? nextServiceDescription;
  
  Repair({
    required this.id,
    required this.vehicleId,
    required this.description,
    required this.startDate,
    this.completionDate,
    this.cost,
    required this.status,
    this.mechanic,
    this.partsUsed,
    this.laborHours,
    this.nextServiceEstimate,
    this.totalDays,
    required this.date,
    this.notes,
    this.nextServiceDueDate,
    this.nextServiceDescription,
  });
  
  factory Repair.fromJson(Map<String, dynamic> json) {
    return Repair(
      id: json['id'],
      vehicleId: json['vehicle_id'],
      description: json['description'],
      startDate: DateTime.parse(json['start_date']),
      completionDate: json['completion_date'] != null 
          ? DateTime.parse(json['completion_date']) 
          : null,
      cost: json['cost']?.toDouble(),
      status: json['status'],
      mechanic: json['mechanic'],
      partsUsed: json['parts_used'],
      laborHours: json['labor_hours']?.toDouble(),
      nextServiceEstimate: json['next_service_estimate'] != null 
          ? DateTime.parse(json['next_service_estimate']) 
          : null,
      totalDays: json['total_days'],
      date: json['date'] != null 
          ? DateTime.parse(json['date']) 
          : DateTime.now(),
      notes: json['notes'],
      nextServiceDueDate: json['next_service_due_date'] != null 
          ? DateTime.parse(json['next_service_due_date']) 
          : null,
      nextServiceDescription: json['next_service_description'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'description': description,
      'start_date': startDate.toIso8601String().split('T').first,
      'completion_date': completionDate?.toIso8601String().split('T').first,
      'cost': cost,
      'status': status,
      'mechanic': mechanic,
      'parts_used': partsUsed,
      'labor_hours': laborHours,
      'next_service_estimate': nextServiceEstimate?.toIso8601String().split('T').first,
      'date': date.toIso8601String().split('T').first,
      'notes': notes,
      'next_service_due_date': nextServiceDueDate?.toIso8601String().split('T').first,
      'next_service_description': nextServiceDescription,
    };
  }
  
  bool get isCompleted => status == 'completed';
  bool get isInProgress => status == 'in_progress';
  bool get isScheduled => status == 'scheduled';
  bool get isCancelled => status == 'cancelled';
} 