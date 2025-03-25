import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';
import '../widgets/loading_indicator.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({Key? key}) : super(key: key);

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final CustomerService _customerService = CustomerService();
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // Customer form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
  List<Customer> _customers = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _perPage = 10;
  int _total = 0;
  bool _isLoading = false;
  bool _isEditing = false;
  int? _editingCustomerId;
  String? _sortBy = 'name';
  bool _sortAsc = true;
  
  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
  
  Future<void> _loadCustomers() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final result = await _customerService.getCustomers(
        page: _currentPage,
        perPage: _perPage,
        search: _searchController.text.isEmpty ? null : _searchController.text,
        sortBy: _sortBy,
        sortAsc: _sortAsc,
      );
      
      setState(() {
        _customers = result['customers'] as List<Customer>;
        _total = result['total'] as int;
        _currentPage = result['page'] as int;
        _perPage = result['per_page'] as int;
        _totalPages = result['total_pages'] as int;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading customers: $e')),
      );
    }
  }
  
  void _resetForm() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _addressController.clear();
    _editingCustomerId = null;
    _isEditing = false;
    _formKey.currentState?.reset();
  }
  
  Future<void> _saveCustomer() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final customerData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
      };
      
      if (_isEditing && _editingCustomerId != null) {
        await _customerService.updateCustomer(_editingCustomerId!, customerData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer updated successfully')),
        );
      } else {
        await _customerService.createCustomer(customerData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer created successfully')),
        );
      }
      
      _resetForm();
      await _loadCustomers();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving customer: $e')),
      );
    }
  }
  
  Future<void> _editCustomer(Customer customer) async {
    setState(() {
      _isEditing = true;
      _editingCustomerId = customer.id;
      _nameController.text = customer.name;
      _emailController.text = customer.email;
      _phoneController.text = customer.phone;
      _addressController.text = customer.address ?? '';
    });
    
    // Show the form dialog
    await _showFormDialog();
  }
  
  Future<void> _deleteCustomer(Customer customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${customer.name}?'),
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
    
    if (confirmed != true) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _customerService.deleteCustomer(customer.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer deleted successfully')),
      );
      
      await _loadCustomers();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting customer: $e')),
      );
    }
  }
  
  Future<void> _showFormDialog() async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isEditing ? 'Edit Customer' : 'Add New Customer'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'Enter customer name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter email address',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      
                      final emailRegex = RegExp(
                        r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
                      );
                      
                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      hintText: 'Enter phone number',
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      hintText: 'Enter address (optional)',
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _resetForm();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() == true) {
                _saveCustomer();
                Navigator.of(context).pop();
              }
            },
            child: Text(_isEditing ? 'Update' : 'Save'),
          ),
        ],
      ),
    );
  }
  
  void _toggleSort(String column) {
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
  
  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(MOBILE);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Management'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCustomers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search customers...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      _loadCustomers();
                                    },
                                  )
                                : null,
                          ),
                          onSubmitted: (_) => _loadCustomers(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          _resetForm();
                          await _showFormDialog();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Customer'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _customers.isEmpty
                      ? const Center(
                          child: Text('No customers found'),
                        )
                      : Scrollbar(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                headingRowColor: MaterialStateProperty.all(
                                  Colors.grey.shade100,
                                ),
                                columns: [
                                  DataColumn(
                                    label: const Text('ID'),
                                    onSort: (_, __) => _toggleSort('id'),
                                  ),
                                  DataColumn(
                                    label: Row(
                                      children: [
                                        const Text('Name'),
                                        if (_sortBy == 'name')
                                          Icon(
                                            _sortAsc
                                                ? Icons.arrow_upward
                                                : Icons.arrow_downward,
                                            size: 16,
                                          ),
                                      ],
                                    ),
                                    onSort: (_, __) => _toggleSort('name'),
                                  ),
                                  DataColumn(
                                    label: Row(
                                      children: [
                                        const Text('Email'),
                                        if (_sortBy == 'email')
                                          Icon(
                                            _sortAsc
                                                ? Icons.arrow_upward
                                                : Icons.arrow_downward,
                                            size: 16,
                                          ),
                                      ],
                                    ),
                                    onSort: (_, __) => _toggleSort('email'),
                                  ),
                                  DataColumn(
                                    label: Row(
                                      children: [
                                        const Text('Phone'),
                                        if (_sortBy == 'phone')
                                          Icon(
                                            _sortAsc
                                                ? Icons.arrow_upward
                                                : Icons.arrow_downward,
                                            size: 16,
                                          ),
                                      ],
                                    ),
                                    onSort: (_, __) => _toggleSort('phone'),
                                  ),
                                  const DataColumn(
                                    label: Text('Address'),
                                  ),
                                  const DataColumn(
                                    label: Text('Actions'),
                                  ),
                                ],
                                rows: _customers.map((customer) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text('#${customer.id}')),
                                      DataCell(Text(customer.name)),
                                      DataCell(Text(customer.email)),
                                      DataCell(Text(customer.phone)),
                                      DataCell(
                                        Text(customer.address ?? 'N/A'),
                                      ),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: Colors.blue),
                                              onPressed: () => _editCustomer(customer),
                                              tooltip: 'Edit',
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () => _deleteCustomer(customer),
                                              tooltip: 'Delete',
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.directions_car, color: Colors.green),
                                              onPressed: () {
                                                // Navigate to vehicles screen filtered by customer
                                                // TODO: Implement this when vehicles screen is created
                                              },
                                              tooltip: 'View Vehicles',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Showing ${_customers.length} of $_total customers'),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _currentPage > 1
                                ? () {
                                    setState(() {
                                      _currentPage--;
                                    });
                                    _loadCustomers();
                                  }
                                : null,
                            icon: const Icon(Icons.chevron_left),
                            tooltip: 'Previous page',
                          ),
                          Text('Page $_currentPage of $_totalPages'),
                          IconButton(
                            onPressed: _currentPage < _totalPages
                                ? () {
                                    setState(() {
                                      _currentPage++;
                                    });
                                    _loadCustomers();
                                  }
                                : null,
                            icon: const Icon(Icons.chevron_right),
                            tooltip: 'Next page',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
} 