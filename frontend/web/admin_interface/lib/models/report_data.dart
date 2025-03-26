class ReportData {
  final List<RevenueData> revenueData;
  final List<ServiceStat> serviceStats;
  final List<PopularService> popularServices;

  ReportData({
    required this.revenueData,
    required this.serviceStats,
    required this.popularServices,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      revenueData: (json['revenue_data'] as List)
          .map((data) => RevenueData.fromJson(data))
          .toList(),
      serviceStats: (json['service_stats'] as List)
          .map((data) => ServiceStat.fromJson(data))
          .toList(),
      popularServices: (json['popular_services'] as List)
          .map((data) => PopularService.fromJson(data))
          .toList(),
    );
  }
}

class RevenueData {
  final DateTime date;
  final double amount;

  RevenueData({
    required this.date,
    required this.amount,
  });

  factory RevenueData.fromJson(Map<String, dynamic> json) {
    return RevenueData(
      date: DateTime.parse(json['date']),
      amount: json['amount'].toDouble(),
    );
  }
}

class ServiceStat {
  final String name;
  final int total;
  final int pending;
  final int completed;

  ServiceStat({
    required this.name,
    required this.total,
    required this.pending,
    required this.completed,
  });

  factory ServiceStat.fromJson(Map<String, dynamic> json) {
    return ServiceStat(
      name: json['name'],
      total: json['total'],
      pending: json['pending'],
      completed: json['completed'],
    );
  }
}

class PopularService {
  final String name;
  final int count;

  PopularService({
    required this.name,
    required this.count,
  });

  factory PopularService.fromJson(Map<String, dynamic> json) {
    return PopularService(
      name: json['name'],
      count: json['count'],
    );
  }
} 