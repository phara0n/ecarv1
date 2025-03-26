class DashboardData {
  final int totalCustomers;
  final int activeRepairs;
  final int pendingInvoices;
  final List<Activity> recentActivity;
  final List<UpcomingService> upcomingServices;

  DashboardData({
    required this.totalCustomers,
    required this.activeRepairs,
    required this.pendingInvoices,
    required this.recentActivity,
    required this.upcomingServices,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalCustomers: json['total_customers'],
      activeRepairs: json['active_repairs'],
      pendingInvoices: json['pending_invoices'],
      recentActivity: (json['recent_activity'] as List)
          .map((data) => Activity.fromJson(data))
          .toList(),
      upcomingServices: (json['upcoming_services'] as List)
          .map((data) => UpcomingService.fromJson(data))
          .toList(),
    );
  }
}

class Activity {
  final String id;
  final String type;
  final String title;
  final String description;
  final DateTime timestamp;

  Activity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class UpcomingService {
  final String id;
  final String vehicleName;
  final String serviceType;
  final DateTime dueDate;

  UpcomingService({
    required this.id,
    required this.vehicleName,
    required this.serviceType,
    required this.dueDate,
  });

  factory UpcomingService.fromJson(Map<String, dynamic> json) {
    return UpcomingService(
      id: json['id'],
      vehicleName: json['vehicle_name'],
      serviceType: json['service_type'],
      dueDate: DateTime.parse(json['due_date']),
    );
  }
} 