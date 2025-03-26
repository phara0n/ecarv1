import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';
import '../widgets/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:data_table_2/data_table_2.dart';
import '../widgets/stat_card.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({Key? key}) : super(key: key);

  @override
  _CustomersScreenState createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CustomerService _customerService = CustomerService();
  
  // State for the customer overview
  bool _isLoadingStats = true;
  Map<String, dynamic> _statistics = {};
  
  // State for the customer list
  bool _isLoadingCustomers = true;
  List<Customer> _customers = [];
  int _totalCustomers = 0;
  int _currentPage = 1;
  int _perPage = 10;
  int _totalPages = 1;
  String? _searchQuery;
  bool? _isActiveFilter;
  String? _sortBy = 'name';
  bool _sortAsc = true;
  
  // State for the customer form
  final _formKey = GlobalKey<FormState>();
  String _formName = '';
  String _formEmail = '';
  String _formPhone = '';
  String _formAddress = '';
  String _formCity = '';
  String _formPostalCode = '';
  String _formNotes = '';
  bool _formIsActive = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStatistics();
    _loadCustomers();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  // Load statistics for the overview tab
  Future<void> _loadStatistics() async {
    setState(() {
      _isLoadingStats = true;
    });
    
    try {
      final stats = await _customerService.getCustomerStatistics();
      setState(() {
        _statistics = stats;
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingStats = false;
      });
      _showSnackBar('Failed to load customer statistics: ${e.toString()}');
    }
  }
  
  // Load customers for the list tab
  Future<void> _loadCustomers() async {
    setState(() {
      _isLoadingCustomers = true;
    });
    
    try {
      final result = await _customerService.getCustomers(
        page: _currentPage,
        perPage: _perPage,
        search: _searchQuery,
        isActive: _isActiveFilter,
        sortBy: _sortBy,
        sortAsc: _sortAsc,
      );
      
      setState(() {
        _customers = result['customers'] as List<Customer>;
        _totalCustomers = result['total'] as int;
        _currentPage = result['page'] as int;
        _perPage = result['per_page'] as int;
        _totalPages = result['total_pages'] as int;
        _isLoadingCustomers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCustomers = false;
      });
      _showSnackBar('Failed to load customers: ${e.toString()}');
    }
  }
  
  // Change page
  void _changePage(int page) {
    if (page != _currentPage) {
      setState(() {
        _currentPage = page;
      });
      _loadCustomers();
    }
  }
  
  // Apply filters
  void _applyFilters() {
    setState(() {
      _currentPage = 1;
    });
    _loadCustomers();
  }
  
  // Reset filters
  void _resetFilters() {
    setState(() {
      _searchQuery = null;
      _isActiveFilter = null;
      _currentPage = 1;
    });
    _loadCustomers();
  }
  
  // Sort customers
  void _sortCustomers(String column) {
    setState(() {
      if (_sortBy == column) {
        _sortAsc = !_sortAsc;
      } else {
        _sortBy = column;
        _sortAsc = true;
      }
    });
    _loadCustomers();
  }
  
  // Show a form dialog to add/edit a customer
  Future<void> _showCustomerForm({Customer? customer}) async {
    // Reset form values
    _formName = customer?.name ?? '';
    _formEmail = customer?.email ?? '';
    _formPhone = customer?.phone ?? '';
    _formAddress = customer?.address ?? '';
    _formCity = customer?.city ?? '';
    _formPostalCode = customer?.postalCode ?? '';
    _formNotes = customer?.notes ?? '';
    _formIsActive = customer?.isActive ?? true;
    
    final isEditing = customer != null;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Customer' : 'Add New Customer'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: _formName,
                  decoration: const InputDecoration(
                    labelText: 'Full Name*',
                    hintText: 'Enter customer\'s full name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  onChanged: (value) => _formName = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _formEmail,
                  decoration: const InputDecoration(
                    labelText: 'Email Address*',
                    hintText: 'Enter email address',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  onChanged: (value) => _formEmail = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _formPhone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter phone number',
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => _formPhone = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _formAddress,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    hintText: 'Enter street address',
                  ),
                  onChanged: (value) => _formAddress = value,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _formCity,
                        decoration: const InputDecoration(
                          labelText: 'City',
                          hintText: 'Enter city',
                        ),
                        onChanged: (value) => _formCity = value,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        initialValue: _formPostalCode,
                        decoration: const InputDecoration(
                          labelText: 'Postal Code',
                          hintText: 'Enter postal code',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _formPostalCode = value,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _formNotes,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Additional customer notes',
                  ),
                  maxLines: 3,
                  onChanged: (value) => _formNotes = value,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Active Customer'),
                  value: _formIsActive,
                  onChanged: (value) {
                    setState(() {
                      _formIsActive = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      final customerData = {
        'name': _formName,
        'email': _formEmail,
        'phone': _formPhone,
        'address': _formAddress,
        'city': _formCity,
        'postal_code': _formPostalCode,
        'is_active': _formIsActive,
        'notes': _formNotes,
      };
      
      try {
        if (isEditing) {
          await _customerService.updateCustomer(customer!.id, customerData);
          _showSnackBar('Customer updated successfully');
        } else {
          await _customerService.createCustomer(customerData);
          _showSnackBar('Customer added successfully');
        }
        _loadCustomers();
        _loadStatistics();
      } catch (e) {
        _showSnackBar('Failed to ${isEditing ? 'update' : 'add'} customer: ${e.toString()}');
      }
    }
  }
  
  // Delete a customer
  Future<void> _deleteCustomer(Customer customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete ${customer.name}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await _customerService.deleteCustomer(customer.id);
        _showSnackBar('Customer deleted successfully');
        _loadCustomers();
        _loadStatistics();
      } catch (e) {
        _showSnackBar('Failed to delete customer: ${e.toString()}');
      }
    }
  }
  
  // Toggle customer active status
  Future<void> _toggleCustomerStatus(Customer customer) async {
    try {
      await _customerService.toggleCustomerStatus(customer.id, !customer.isActive);
      _showSnackBar('Customer status updated successfully');
      _loadCustomers();
      _loadStatistics();
    } catch (e) {
      _showSnackBar('Failed to update customer status: ${e.toString()}');
    }
  }
  
  // Show a snackbar with a message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
  
  // Build the customer list tab
  Widget _buildCustomerListTab() {
    return Column(
      children: [
        // Filters section
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Search',
                            hintText: 'Customer name, email, phone...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.isNotEmpty ? value : null;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<bool?>(
                        hint: const Text('Status'),
                        value: _isActiveFilter,
                        items: const [
                          DropdownMenuItem<bool?>(
                            value: null,
                            child: Text('All Statuses'),
                          ),
                          DropdownMenuItem<bool?>(
                            value: true,
                            child: Text('Active'),
                          ),
                          DropdownMenuItem<bool?>(
                            value: false,
                            child: Text('Inactive'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _isActiveFilter = value;
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _applyFilters,
                        child: const Text('Apply Filters'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _resetFilters,
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Customer data table
        Expanded(
          child: _isLoadingCustomers
              ? const Center(child: CircularProgressIndicator())
              : _buildCustomersDataTable(),
        ),
        
        // Pagination controls
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.first_page),
                onPressed: _currentPage > 1 ? () => _changePage(1) : null,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentPage > 1 ? () => _changePage(_currentPage - 1) : null,
              ),
              const SizedBox(width: 8),
              Text('Page $_currentPage of $_totalPages'),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _currentPage < _totalPages ? () => _changePage(_currentPage + 1) : null,
              ),
              IconButton(
                icon: const Icon(Icons.last_page),
                onPressed: _currentPage < _totalPages ? () => _changePage(_totalPages) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Build the top cities chart
  Widget _buildTopCitiesChart() {
    final topCities = _statistics['top_cities'] as List<dynamic>? ?? [];
    
    if (topCities.isEmpty) {
      return const Center(child: Text('No data available'));
    }
    
    // Process the list format [{'name': 'City', 'count': Number}]
    final citiesList = topCities.map((city) => {
      'name': city['name'] as String,
      'count': city['count'] as int
    }).toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    
    final barGroups = <BarChartGroupData>[];
    final titles = <String>[];
    
    for (int i = 0; i < citiesList.length && i < 5; i++) {
      final city = citiesList[i];
      titles.add(city['name'] as String);
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: (city['count'] as int).toDouble(),
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
        maxY: (citiesList.isNotEmpty ? (citiesList.first['count'] as int).toDouble() * 1.2 : 10),
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
  
  // Build the customers data table
  Widget _buildCustomersDataTable() {
    if (_customers.isEmpty) {
      return const Center(
        child: Text('No customers found matching your criteria'),
      );
    }
    
    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 900,
      sortColumnIndex: _sortBy == 'name' ? 0 : 
                      _sortBy == 'email' ? 1 :
                      _sortBy == 'created_at' ? 5 :
                      _sortBy == 'vehicle_count' ? 6 : null,
      sortAscending: _sortAsc,
      columns: [
        DataColumn2(
          label: const Text('Name'),
          onSort: (_, __) => _sortCustomers('name'),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: const Text('Email'),
          onSort: (_, __) => _sortCustomers('email'),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: const Text('Phone'),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: const Text('City'),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: const Text('Status'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: const Text('Joined'),
          onSort: (_, __) => _sortCustomers('created_at'),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: const Text('Vehicles'),
          onSort: (_, __) => _sortCustomers('vehicle_count'),
          numeric: true,
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: const Text('Total Spent'),
          size: ColumnSize.M,
        ),
        const DataColumn2(
          label: Text('Actions'),
          size: ColumnSize.M,
        ),
      ],
      rows: _customers.map((customer) {
        return DataRow2(
          cells: [
            DataCell(
              Row(
                children: [
                  customer.getAvatar(radius: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(customer.name)),
                ],
              ),
            ),
            DataCell(Text(customer.email)),
            DataCell(Text(customer.phone ?? 'N/A')),
            DataCell(Text(customer.city ?? 'N/A')),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Customer.getStatusColor(customer.isActive).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  Customer.getStatusText(customer.isActive),
                  style: TextStyle(
                    color: Customer.getStatusColor(customer.isActive),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            DataCell(Text(customer.formattedCreatedAt())),
            DataCell(Text(customer.vehicleCount.toString())),
            DataCell(Text(customer.formattedTotalSpent())),
            DataCell(Row(
              children: [
                // Edit button
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  tooltip: 'Edit Customer',
                  onPressed: () => _showCustomerForm(customer: customer),
                ),
                // Toggle status button
                IconButton(
                  icon: Icon(
                    customer.isActive ? Icons.person_off : Icons.person,
                    size: 20,
                    color: customer.isActive ? Colors.red : Colors.green,
                  ),
                  tooltip: customer.isActive ? 'Mark as Inactive' : 'Mark as Active',
                  onPressed: () => _toggleCustomerStatus(customer),
                ),
                // More options button
                PopupMenuButton<String>(
                  tooltip: 'More Actions',
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (String action) {
                    switch (action) {
                      case 'vehicles':
                        // Navigate to vehicles filtered by this customer
                        _showSnackBar('View vehicles would be implemented here');
                        break;
                      case 'repairs':
                        // Navigate to repairs filtered by this customer
                        _showSnackBar('View repairs would be implemented here');
                        break;
                      case 'invoices':
                        // Navigate to invoices filtered by this customer
                        _showSnackBar('View invoices would be implemented here');
                        break;
                      case 'delete':
                        _deleteCustomer(customer);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'vehicles',
                      child: ListTile(
                        leading: Icon(Icons.directions_car),
                        title: Text('View Vehicles'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'repairs',
                      child: ListTile(
                        leading: Icon(Icons.build),
                        title: Text('View Repairs'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'invoices',
                      child: ListTile(
                        leading: Icon(Icons.receipt),
                        title: Text('View Invoices'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Delete Customer'),
                      ),
                    ),
                  ],
                ),
              ],
            )),
          ],
        );
      }).toList(),
    );
  }
} 