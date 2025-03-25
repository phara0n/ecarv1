import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../models/vehicle.dart';
import '../models/customer.dart';
import '../services/vehicle_service.dart';
import '../services/customer_service.dart';
import '../widgets/loading_indicator.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({Key? key}) : super(key: key);

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final VehicleService _vehicleService = VehicleService();
  final CustomerService _customerService = CustomerService();
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // Vehicle form controllers
  final _customerIdController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _mileageController = TextEditingController();
  final _averageDailyUsageController = TextEditingController();
  
  List<Vehicle> _vehicles = [];
  List<Customer> _customers = [];
  Map<String, List<String>> _vehicleOptions = {};
  List<String> _modelOptions = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _perPage = 10;
  int _total = 0;
  bool _isLoading = false;
  bool _isFormLoading = false;
  bool _isEditing = false;
  int? _editingVehicleId;
  String? _sortBy = 'brand';
  bool _sortAsc = true;
  String? _selectedBrand;
  int? _selectedCustomerId;
  
  @override
  void initState() {
    super.initState();
    _loadVehicles();
    _loadCustomers();
    _loadVehicleOptions();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _customerIdController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _licensePlateController.dispose();
    _mileageController.dispose();
    _averageDailyUsageController.dispose();
    super.dispose();
  }
  
  Future<void> _loadVehicles() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final result = await _vehicleService.getVehicles(
        page: _currentPage,
        perPage: _perPage,
        search: _searchController.text.isEmpty ? null : _searchController.text,
        customerId: _selectedCustomerId,
        brand: _selectedBrand,
        sortBy: _sortBy,
        sortAsc: _sortAsc,
      );
      
      setState(() {
        _vehicles = result['vehicles'] as List<Vehicle>;
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
        SnackBar(content: Text('Error loading vehicles: $e')),
      );
    }
  }
  
  Future<void> _loadCustomers() async {
    try {
      final result = await _customerService.getCustomers(perPage: 100);
      
      setState(() {
        _customers = result['customers'] as List<Customer>;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading customers: $e')),
      );
    }
  }
  
  Future<void> _loadVehicleOptions() async {
    try {
      final options = await _vehicleService.getVehicleOptions();
      
      setState(() {
        _vehicleOptions = options;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading vehicle options: $e')),
      );
    }
  }
  
  void _updateModelOptions(String brand) {
    setState(() {
      _selectedBrand = brand;
      _modelOptions = _vehicleOptions[brand] ?? [];
      _modelController.text = '';
    });
  }
  
  void _resetForm() {
    _customerIdController.clear();
    _brandController.clear();
    _modelController.clear();
    _yearController.clear();
    _licensePlateController.clear();
    _mileageController.clear();
    _averageDailyUsageController.clear();
    _editingVehicleId = null;
    _isEditing = false;
    _modelOptions = [];
    _selectedBrand = null;
    _selectedCustomerId = null;
    _formKey.currentState?.reset();
  }
  
  Future<void> _saveVehicle() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    setState(() {
      _isFormLoading = true;
    });
    
    try {
      final vehicleData = {
        'customer_id': int.parse(_customerIdController.text),
        'brand': _brandController.text,
        'model': _modelController.text,
        'year': int.parse(_yearController.text),
        'license_plate': _licensePlateController.text,
        'current_mileage': int.parse(_mileageController.text),
        'average_daily_usage': double.parse(_averageDailyUsageController.text),
      };
      
      if (_isEditing && _editingVehicleId != null) {
        await _vehicleService.updateVehicle(_editingVehicleId!, vehicleData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle updated successfully')),
        );
      } else {
        await _vehicleService.createVehicle(vehicleData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle created successfully')),
        );
      }
      
      _resetForm();
      await _loadVehicles();
    } catch (e) {
      setState(() {
        _isFormLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving vehicle: $e')),
      );
    }
  }
  
  Future<void> _editVehicle(Vehicle vehicle) async {
    // Find the customer and brand to set up the dropdown options
    final customer = _customers.firstWhere(
      (c) => c.id == vehicle.customerId,
      orElse: () => _customers.first,
    );
    
    setState(() {
      _isEditing = true;
      _editingVehicleId = vehicle.id;
      _selectedCustomerId = vehicle.customerId;
      _customerIdController.text = vehicle.customerId.toString();
      _brandController.text = vehicle.brand;
      _modelController.text = vehicle.model;
      _yearController.text = vehicle.year.toString();
      _licensePlateController.text = vehicle.licensePlate;
      _mileageController.text = vehicle.currentMileage.toString();
      _averageDailyUsageController.text = vehicle.averageDailyUsage.toString();
      
      // Set up brand and model options
      _selectedBrand = vehicle.brand;
      _modelOptions = _vehicleOptions[vehicle.brand] ?? [];
    });
    
    // Show the form dialog
    await _showFormDialog();
  }
  
  Future<void> _deleteVehicle(Vehicle vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${vehicle.brand} ${vehicle.model} (${vehicle.licensePlate})?'),
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
      await _vehicleService.deleteVehicle(vehicle.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle deleted successfully')),
      );
      
      await _loadVehicles();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting vehicle: $e')),
      );
    }
  }
  
  Future<void> _updateMileage(Vehicle vehicle) async {
    final TextEditingController mileageController = TextEditingController(
      text: vehicle.currentMileage.toString(),
    );
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Mileage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${vehicle.brand} ${vehicle.model} (${vehicle.licensePlate})'),
            const SizedBox(height: 16),
            TextFormField(
              controller: mileageController,
              decoration: const InputDecoration(
                labelText: 'Current Mileage (km)',
                hintText: 'Enter current mileage',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the current mileage';
                }
                
                final mileage = int.tryParse(value);
                if (mileage == null || mileage < vehicle.currentMileage) {
                  return 'Mileage must be greater than or equal to the current value';
                }
                
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Update'),
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
      final mileage = int.parse(mileageController.text);
      await _vehicleService.updateMileage(vehicle.id, mileage);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mileage updated successfully')),
      );
      
      await _loadVehicles();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating mileage: $e')),
      );
    } finally {
      mileageController.dispose();
    }
  }
  
  Future<void> _showFormDialog() async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isEditing ? 'Edit Vehicle' : 'Add New Vehicle'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Customer dropdown
                  DropdownButtonFormField<int>(
                    value: _selectedCustomerId,
                    decoration: const InputDecoration(
                      labelText: 'Customer',
                      hintText: 'Select a customer',
                    ),
                    items: _customers.map((customer) {
                      return DropdownMenuItem<int>(
                        value: customer.id,
                        child: Text(customer.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCustomerId = value;
                        _customerIdController.text = value.toString();
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a customer';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Brand dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedBrand,
                    decoration: const InputDecoration(
                      labelText: 'Brand',
                      hintText: 'Select a brand',
                    ),
                    items: _vehicleOptions.keys.map((brand) {
                      return DropdownMenuItem<String>(
                        value: brand,
                        child: Text(brand),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _updateModelOptions(value);
                        _brandController.text = value;
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a brand';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Model dropdown
                  DropdownButtonFormField<String>(
                    value: _modelOptions.contains(_modelController.text) 
                        ? _modelController.text 
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Model',
                      hintText: 'Select a model',
                    ),
                    items: _modelOptions.map((model) {
                      return DropdownMenuItem<String>(
                        value: model,
                        child: Text(model),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _modelController.text = value;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a model';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Year
                  TextFormField(
                    controller: _yearController,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      hintText: 'Enter vehicle year',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the year';
                      }
                      
                      final year = int.tryParse(value);
                      if (year == null || year < 1900 || year > DateTime.now().year + 1) {
                        return 'Please enter a valid year';
                      }
                      
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // License Plate
                  TextFormField(
                    controller: _licensePlateController,
                    decoration: const InputDecoration(
                      labelText: 'License Plate',
                      hintText: 'Enter license plate number',
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the license plate';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Current Mileage
                  TextFormField(
                    controller: _mileageController,
                    decoration: const InputDecoration(
                      labelText: 'Current Mileage (km)',
                      hintText: 'Enter current mileage',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the current mileage';
                      }
                      
                      final mileage = int.tryParse(value);
                      if (mileage == null || mileage < 0) {
                        return 'Please enter a valid mileage';
                      }
                      
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Average Daily Usage
                  TextFormField(
                    controller: _averageDailyUsageController,
                    decoration: const InputDecoration(
                      labelText: 'Average Daily Usage (km)',
                      hintText: 'Enter average daily usage',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the average daily usage';
                      }
                      
                      final usage = double.tryParse(value);
                      if (usage == null || usage < 0) {
                        return 'Please enter a valid usage value';
                      }
                      
                      return null;
                    },
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
          _isFormLoading
              ? const SizedBox(
                  width: 80,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
              : ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() == true) {
                      _saveVehicle();
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
    
    _loadVehicles();
  }
  
  String _getCustomerName(int customerId) {
    final customer = _customers.firstWhere(
      (c) => c.id == customerId,
      orElse: () => Customer(
        id: 0,
        name: 'Unknown',
        email: '',
        phone: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    
    return customer.name;
  }
  
  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(MOBILE);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Management'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVehicles,
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
                            hintText: 'Search vehicles...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      _loadVehicles();
                                    },
                                  )
                                : null,
                          ),
                          onSubmitted: (_) => _loadVehicles(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          _resetForm();
                          await _showFormDialog();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Vehicle'),
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
                
                // Filter options row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      // Brand filter dropdown
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          value: _selectedBrand,
                          decoration: const InputDecoration(
                            labelText: 'Filter by Brand',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('All Brands'),
                            ),
                            ..._vehicleOptions.keys.map((brand) {
                              return DropdownMenuItem<String?>(
                                value: brand,
                                child: Text(brand),
                              );
                            }).toList(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedBrand = value;
                              _currentPage = 1;
                            });
                            _loadVehicles();
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Customer filter dropdown
                      Expanded(
                        child: DropdownButtonFormField<int?>(
                          value: _selectedCustomerId,
                          decoration: const InputDecoration(
                            labelText: 'Filter by Customer',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('All Customers'),
                            ),
                            ..._customers.map((customer) {
                              return DropdownMenuItem<int?>(
                                value: customer.id,
                                child: Text(customer.name),
                              );
                            }).toList(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCustomerId = value;
                              _currentPage = 1;
                            });
                            _loadVehicles();
                          },
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      // Clear filters button
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedBrand = null;
                            _selectedCustomerId = null;
                            _currentPage = 1;
                          });
                          _loadVehicles();
                        },
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Clear Filters'),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Expanded(
                  child: _vehicles.isEmpty
                      ? const Center(
                          child: Text('No vehicles found'),
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
                                        const Text('Brand'),
                                        if (_sortBy == 'brand')
                                          Icon(
                                            _sortAsc
                                                ? Icons.arrow_upward
                                                : Icons.arrow_downward,
                                            size: 16,
                                          ),
                                      ],
                                    ),
                                    onSort: (_, __) => _toggleSort('brand'),
                                  ),
                                  DataColumn(
                                    label: Row(
                                      children: [
                                        const Text('Model'),
                                        if (_sortBy == 'model')
                                          Icon(
                                            _sortAsc
                                                ? Icons.arrow_upward
                                                : Icons.arrow_downward,
                                            size: 16,
                                          ),
                                      ],
                                    ),
                                    onSort: (_, __) => _toggleSort('model'),
                                  ),
                                  DataColumn(
                                    label: Row(
                                      children: [
                                        const Text('Year'),
                                        if (_sortBy == 'year')
                                          Icon(
                                            _sortAsc
                                                ? Icons.arrow_upward
                                                : Icons.arrow_downward,
                                            size: 16,
                                          ),
                                      ],
                                    ),
                                    onSort: (_, __) => _toggleSort('year'),
                                  ),
                                  DataColumn(
                                    label: Row(
                                      children: [
                                        const Text('License Plate'),
                                        if (_sortBy == 'license_plate')
                                          Icon(
                                            _sortAsc
                                                ? Icons.arrow_upward
                                                : Icons.arrow_downward,
                                            size: 16,
                                          ),
                                      ],
                                    ),
                                    onSort: (_, __) => _toggleSort('license_plate'),
                                  ),
                                  DataColumn(
                                    label: const Text('Customer'),
                                    onSort: (_, __) => _toggleSort('customer_id'),
                                  ),
                                  DataColumn(
                                    label: Row(
                                      children: [
                                        const Text('Mileage'),
                                        if (_sortBy == 'current_mileage')
                                          Icon(
                                            _sortAsc
                                                ? Icons.arrow_upward
                                                : Icons.arrow_downward,
                                            size: 16,
                                          ),
                                      ],
                                    ),
                                    onSort: (_, __) => _toggleSort('current_mileage'),
                                    numeric: true,
                                  ),
                                  DataColumn(
                                    label: const Text('Est. Next Service'),
                                  ),
                                  DataColumn(
                                    label: const Text('Actions'),
                                  ),
                                ],
                                rows: _vehicles.map((vehicle) {
                                  // Calculate estimated days until next service
                                  final daysUntilService = vehicle.estimatedDaysUntilNextService();
                                  
                                  return DataRow(
                                    cells: [
                                      DataCell(Text('#${vehicle.id}')),
                                      DataCell(Text(vehicle.brand)),
                                      DataCell(Text(vehicle.model)),
                                      DataCell(Text(vehicle.year.toString())),
                                      DataCell(Text(vehicle.licensePlate)),
                                      DataCell(Text(vehicle.customerName ?? _getCustomerName(vehicle.customerId))),
                                      DataCell(
                                        Text(
                                          '${NumberFormat("#,###").format(vehicle.currentMileage)} km',
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: daysUntilService < 30
                                                ? Colors.red.shade50
                                                : daysUntilService < 90
                                                    ? Colors.orange.shade50
                                                    : Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            daysUntilService < 30
                                                ? 'Soon (${daysUntilService} days)'
                                                : daysUntilService < 90
                                                    ? 'In ${daysUntilService} days'
                                                    : 'In ${(daysUntilService / 30).round()} months',
                                            style: TextStyle(
                                              color: daysUntilService < 30
                                                  ? Colors.red.shade800
                                                  : daysUntilService < 90
                                                      ? Colors.orange.shade800
                                                      : Colors.green.shade800,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: Colors.blue),
                                              onPressed: () => _editVehicle(vehicle),
                                              tooltip: 'Edit',
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () => _deleteVehicle(vehicle),
                                              tooltip: 'Delete',
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.speed, color: Colors.green),
                                              onPressed: () => _updateMileage(vehicle),
                                              tooltip: 'Update Mileage',
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.build, color: Colors.orange),
                                              onPressed: () {
                                                // Navigate to repairs filtered by vehicle
                                                // TODO: Implement when repairs screen is created
                                              },
                                              tooltip: 'View Repairs',
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
                      Text('Showing ${_vehicles.length} of $_total vehicles'),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _currentPage > 1
                                ? () {
                                    setState(() {
                                      _currentPage--;
                                    });
                                    _loadVehicles();
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
                                    _loadVehicles();
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