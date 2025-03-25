import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CustomersScreenPart3 extends StatefulWidget {
  const CustomersScreenPart3({Key? key}) : super(key: key);

  @override
  _CustomersScreenPart3State createState() => _CustomersScreenPart3State();
}

class _CustomersScreenPart3State extends State<CustomersScreenPart3> {
  late TabController _tabController;
  bool _isLoadingStats = true;
  Map<String, dynamic> _statistics = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Customer List'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildCustomerListTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCustomerForm(),
        child: const Icon(Icons.add),
        tooltip: 'Add New Customer',
      ),
    );
  }
  
  // Build the overview tab
  Widget _buildOverviewTab() {
    if (_isLoadingStats) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final currencyFormat = NumberFormat.currency(symbol: 'TND ', decimalDigits: 2);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Statistics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Statistics cards
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 
                           (MediaQuery.of(context).size.width > 800 ? 2 : 1),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              StatCard(
                title: 'Total Customers',
                value: _statistics['total_customers']?.toString() ?? '0',
                icon: Icons.people,
                color: Colors.blue,
              ),
              StatCard(
                title: 'Active Customers',
                value: _statistics['active_customers']?.toString() ?? '0',
                icon: Icons.person,
                color: Colors.green,
              ),
              StatCard(
                title: 'New This Month',
                value: _statistics['new_last_month']?.toString() ?? '0',
                icon: Icons.person_add,
                color: Colors.orange,
              ),
              StatCard(
                title: 'Total Revenue',
                value: currencyFormat.format(_statistics['total_revenue'] ?? 0),
                icon: Icons.attach_money,
                color: Colors.purple,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Top cities chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customers by City',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: _buildTopCitiesChart(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Customer growth chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customer Growth',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: _buildCustomerGrowthChart(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Vehicles per customer chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vehicles per Customer',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: _buildVehiclesPerCustomerChart(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Recent customers card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Customers',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildRecentCustomersTable(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Build the top cities chart
  Widget _buildTopCitiesChart() {
    final topCities = _statistics['top_cities'] as Map<String, dynamic>? ?? {};
    
    if (topCities.isEmpty) {
      return const Center(child: Text('No data available'));
    }
    
    final entries = topCities.entries.toList()
      ..sort((a, b) => (b.value as int).compareTo(a.value as int));
    
    final barGroups = <BarChartGroupData>[];
    final titles = <String>[];
    
    for (int i = 0; i < entries.length && i < 5; i++) {
      final entry = entries[i];
      titles.add(entry.key);
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: (entry.value as int).toDouble(),
              color: Colors.blue,
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    }
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (entries.isNotEmpty ? (entries.first.value as int).toDouble() * 1.2 : 10),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < 0 || value.toInt() >= titles.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    titles[value.toInt()],
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
        gridData: FlGridData(show: true),
      ),
    );
  }
  
  // Build the customer growth chart
  Widget _buildCustomerGrowthChart() {
    final customerGrowth = _statistics['customer_growth'] as Map<String, dynamic>? ?? {};
    
    if (customerGrowth.isEmpty) {
      return const Center(child: Text('No data available'));
    }
    
    final spots = <FlSpot>[];
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    for (int i = 0; i < months.length; i++) {
      final month = months[i];
      final count = customerGrowth[month] as int? ?? 0;
      spots.add(FlSpot(i.toDouble(), count.toDouble()));
    }
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < 0 || value.toInt() >= months.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(months[value.toInt()]),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            color: Colors.green,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
  
  // Build the vehicles per customer chart
  Widget _buildVehiclesPerCustomerChart() {
    final vehiclesPerCustomer = _statistics['vehicles_per_customer'] as Map<String, dynamic>? ?? {};
    
    if (vehiclesPerCustomer.isEmpty) {
      return const Center(child: Text('No data available'));
    }
    
    final pieChartSections = <PieChartSectionData>[];
    final colors = [Colors.blue, Colors.green, Colors.orange];
    
    int i = 0;
    vehiclesPerCustomer.forEach((key, value) {
      final count = value as int;
      if (count > 0) {
        pieChartSections.add(
          PieChartSectionData(
            color: colors[i % colors.length],
            value: count.toDouble(),
            title: '$key\n$count',
            radius: 120,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }
      i++;
    });
    
    return pieChartSections.isEmpty
        ? const Center(child: Text('No data available'))
        : PieChart(
            PieChartData(
              sections: pieChartSections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          );
  }
  
  // Build the recent customers table
  Widget _buildRecentCustomersTable() {
    final recentCustomers = _statistics['recent_customers'] as List<dynamic>? ?? [];
    
    if (recentCustomers.isEmpty) {
      return const Center(child: Text('No recent customers'));
    }
    
    return DataTable(
      columns: const [
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Email')),
        DataColumn(label: Text('Joined')),
        DataColumn(label: Text('Vehicles')),
        DataColumn(label: Text('Status')),
      ],
      rows: recentCustomers.map<DataRow>((customer) {
        final isActive = customer['is_active'] as bool;
        return DataRow(
          cells: [
            DataCell(Text(customer['name'] as String)),
            DataCell(Text(customer['email'] as String)),
            DataCell(Text(DateFormat('MMM d, yyyy').format(
              DateTime.parse(customer['created_at'] as String),
            ))),
            DataCell(Text((customer['vehicle_count'] as int).toString())),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Customer.getStatusColor(isActive).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  Customer.getStatusText(isActive),
                  style: TextStyle(
                    color: Customer.getStatusColor(isActive),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  void _loadStatistics() {
    // Implement the logic to load statistics
    // This is a placeholder and should be replaced with actual implementation
    setState(() {
      _isLoadingStats = false;
      _statistics = {
        'total_customers': 100,
        'active_customers': 80,
        'new_last_month': 20,
        'total_revenue': 10000,
        'top_cities': {
          'City1': 50,
          'City2': 30,
          'City3': 20,
          'City4': 10,
          'City5': 5,
        },
        'customer_growth': {
          'Jan': 10,
          'Feb': 12,
          'Mar': 15,
          'Apr': 18,
          'May': 20,
          'Jun': 22,
          'Jul': 25,
          'Aug': 28,
          'Sep': 30,
          'Oct': 32,
          'Nov': 35,
          'Dec': 38,
        },
        'vehicles_per_customer': {
          'Car': 5,
          'Motorcycle': 3,
          'Truck': 2,
        },
        'recent_customers': [
          {
            'name': 'John Doe',
            'email': 'john@example.com',
            'created_at': '2024-03-15T10:00:00',
            'vehicle_count': 2,
            'is_active': true,
          },
          {
            'name': 'Jane Smith',
            'email': 'jane@example.com',
            'created_at': '2024-03-10T11:00:00',
            'vehicle_count': 1,
            'is_active': true,
          },
          {
            'name': 'Bob Johnson',
            'email': 'bob@example.com',
            'created_at': '2024-03-05T12:00:00',
            'vehicle_count': 0,
            'is_active': false,
          },
        ],
      };
    });
  }

  void _showCustomerForm() {
    // Implement the logic to show the customer form
    // This is a placeholder and should be replaced with actual implementation
    print('Show customer form');
  }
} 