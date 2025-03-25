import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:data_table_2/data_table_2.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';
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
} 