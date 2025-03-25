import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../models/repair.dart';
import '../models/vehicle.dart';
import '../models/customer.dart';
import '../services/repair_service.dart';
import '../services/vehicle_service.dart';
import '../services/customer_service.dart';
import '../widgets/loading_indicator.dart';

class RepairsScreen extends StatefulWidget {
  const RepairsScreen({Key? key}) : super(key: key);

  @override
  State<RepairsScreen> createState() => _RepairsScreenState();
}

class _RepairsScreenState extends State<RepairsScreen> with SingleTickerProviderStateMixin {
  final RepairService _repairService = RepairService();
  final VehicleService _vehicleService = VehicleService();
  final CustomerService _customerService = CustomerService();
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // Repair form controllers
  final _vehicleIdController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final _costController = TextEditingController();
  final _statusController = TextEditingController();
  
  List<Repair> _repairs = [];
  List<Vehicle> _vehicles = [];
  List<Customer> _customers = [];
  Map<String, dynamic> _statistics = {};
  int _currentPage = 1;
  int _totalPages = 1;
  int _perPage = 10;
  int _total = 0;
  bool _isLoading = false;
  bool _isStatisticsLoading = false;
  bool _isFormLoading = false;
  bool _isEditing = false;
  int? _editingRepairId;
  String? _sortBy = 'date';
  bool _sortAsc = false;
  int? _selectedVehicleId;
  int? _selectedCustomerId;
  String? _selectedStatus;
  DateTime? _selectedDate;
  DateTime? _startDate;
  DateTime? _endDate;
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRepairs();
    _loadVehicles();
    _loadCustomers();
    _loadStatistics();
    
    // Set default date to today
    _selectedDate = DateTime.now();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _vehicleIdController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _costController.dispose();
    _statusController.dispose();
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadRepairs() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final result = await _repairService.getRepairs(
        page: _currentPage,
        perPage: _perPage,
        search: _searchController.text.isEmpty ? null : _searchController.text,
        vehicleId: _selectedVehicleId,
        customerId: _selectedCustomerId,
        status: _selectedStatus,
        sortBy: _sortBy,
        sortAsc: _sortAsc,
        startDate: _startDate,
        endDate: _endDate,
      );
      
      setState(() {
        _repairs = result['repairs'] as List<Repair>;
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
        SnackBar(content: Text('Error loading repairs: $e')),
      );
    }
  }
  
  Future<void> _loadVehicles() async {
    try {
      final result = await _vehicleService.getVehicles(perPage: 100);
      
      setState(() {
        _vehicles = result['vehicles'] as List<Vehicle>;
      });
    } catch (e) {
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
  
  Future<void> _loadStatistics() async {
    setState(() {
      _isStatisticsLoading = true;
    });
    
    try {
      final statistics = await _repairService.getRepairStatistics();
      
      setState(() {
        _statistics = statistics;
        _isStatisticsLoading = false;
      });
    } catch (e) {
      setState(() {
        _isStatisticsLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading statistics: $e')),
      );
    }
  }
  
  void _resetForm() {
    _vehicleIdController.clear();
    _descriptionController.clear();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _costController.clear();
    _statusController.text = 'pending';
    _editingRepairId = null;
    _isEditing = false;
    _selectedVehicleId = null;
    _selectedDate = DateTime.now();
    _formKey.currentState?.reset();
  }
  
  Future<void> _saveRepair() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    setState(() {
      _isFormLoading = true;
    });
    
    try {
      final repairData = {
        'vehicle_id': int.parse(_vehicleIdController.text),
        'description': _descriptionController.text,
        'date': _dateController.text,
        'cost': double.parse(_costController.text),
        'status': _statusController.text.isEmpty ? 'pending' : _statusController.text,
      };
      
      if (_isEditing && _editingRepairId != null) {
        await _repairService.updateRepair(_editingRepairId!, repairData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Repair updated successfully')),
        );
      } else {
        await _repairService.createRepair(repairData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Repair created successfully')),
        );
      }
      
      _resetForm();
      await _loadRepairs();
      await _loadStatistics();
    } catch (e) {
      setState(() {
        _isFormLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving repair: $e')),
      );
    }
  }
  
  Future<void> _editRepair(Repair repair) async {
    // Find the vehicle to set up the dropdown options
    final vehicle = _vehicles.firstWhere(
      (v) => v.id == repair.vehicleId,
      orElse: () => _vehicles.isNotEmpty ? _vehicles.first : Vehicle(
        id: 0,
        customerId: 0,
        brand: 'Unknown',
        model: 'Unknown',
        year: DateTime.now().year,
        licensePlate: 'Unknown',
        currentMileage: 0,
        averageDailyUsage: 0,
        lastServiceDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    
    setState(() {
      _isEditing = true;
      _editingRepairId = repair.id;
      _selectedVehicleId = repair.vehicleId;
      _vehicleIdController.text = repair.vehicleId.toString();
      _descriptionController.text = repair.description;
      _dateController.text = DateFormat('yyyy-MM-dd').format(repair.date);
      _costController.text = repair.cost.toString();
      _statusController.text = repair.status;
      _selectedDate = repair.date;
    });
    
    // Show the form dialog
    await _showFormDialog();
  }
  
  Future<void> _deleteRepair(Repair repair) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this repair for ${repair.vehicleBrand} ${repair.vehicleModel}?'),
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
      await _repairService.deleteRepair(repair.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Repair deleted successfully')),
      );
      
      await _loadRepairs();
      await _loadStatistics();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting repair: $e')),
      );
    }
  }
  
  Future<void> _updateStatus(Repair repair, String newStatus) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _repairService.updateStatus(repair.id, newStatus);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to ${Repair.getStatusName(newStatus)}')),
      );
      
      await _loadRepairs();
      await _loadStatistics();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
  
  Future<void> _filterByDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _currentPage = 1;
      });
      
      await _loadRepairs();
    }
  }
  
  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _currentPage = 1;
    });
    
    _loadRepairs();
  }
  
  String _getVehicleInfo(int vehicleId) {
    final vehicle = _vehicles.firstWhere(
      (v) => v.id == vehicleId,
      orElse: () => Vehicle(
        id: 0,
        customerId: 0,
        brand: 'Unknown',
        model: 'Unknown',
        year: DateTime.now().year,
        licensePlate: 'Unknown',
        currentMileage: 0,
        averageDailyUsage: 0,
        lastServiceDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    
    return '${vehicle.brand} ${vehicle.model} (${vehicle.licensePlate})';
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
  
  void _toggleSort(String column) {
    setState(() {
      if (_sortBy == column) {
        _sortAsc = !_sortAsc;
      } else {
        _sortBy = column;
        _sortAsc = true;
      }
    });
    
    _loadRepairs();
  }
  
  Future<void> _showFormDialog() async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isEditing ? 'Edit Repair' : 'Add New Repair'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Vehicle dropdown
                  DropdownButtonFormField<int>(
                    value: _selectedVehicleId,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle',
                      hintText: 'Select a vehicle',
                    ),
                    items: _vehicles.map((vehicle) {
                      return DropdownMenuItem<int>(
                        value: vehicle.id,
                        child: Text(
                          '${vehicle.brand} ${vehicle.model} (${vehicle.licensePlate})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedVehicleId = value;
                        _vehicleIdController.text = value.toString();
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a vehicle';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter repair description',
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Date picker
                  TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      hintText: 'YYYY-MM-DD',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a date';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Cost
                  TextFormField(
                    controller: _costController,
                    decoration: const InputDecoration(
                      labelText: 'Cost (TND)',
                      hintText: 'Enter repair cost',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the cost';
                      }
                      
                      final cost = double.tryParse(value);
                      if (cost == null || cost < 0) {
                        return 'Please enter a valid cost';
                      }
                      
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Status dropdown
                  DropdownButtonFormField<String>(
                    value: _statusController.text.isEmpty 
                        ? 'pending' 
                        : _statusController.text,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      hintText: 'Select status',
                    ),
                    items: Repair.getStatusOptions().map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(Repair.getStatusName(status)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _statusController.text = value;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a status';
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
                      _saveRepair();
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(_isEditing ? 'Update' : 'Save'),
                ),
        ],
      ),
    );
  }
  
  Widget _buildStatisticsCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusDistributionChart() {
    if (_statistics.isEmpty || _statistics['status_distribution'] == null) {
      return const SizedBox.shrink();
    }
    
    final distribution = _statistics['status_distribution'] as Map<String, dynamic>;
    final total = _statistics['total_repairs'] as int? ?? 0;
    
    if (total == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No data available'),
        ),
      );
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Repair Status Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...distribution.entries.map((entry) {
              final status = entry.key;
              final count = entry.value as int;
              final percent = (count / total * 100).round();
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Repair.getStatusName(status),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text('$count ($percent%)'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: count / total,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Repair.getStatusColor(status),
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentRepairsCard() {
    if (_statistics.isEmpty || _statistics['recent_repairs'] == null) {
      return const SizedBox.shrink();
    }
    
    final recentRepairs = _statistics['recent_repairs'] as List;
    
    if (recentRepairs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No recent repairs'),
        ),
      );
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Repairs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...recentRepairs.map((repair) {
              final id = repair['id'] as int;
              final description = repair['description'] as String;
              final date = DateTime.parse(repair['date'] as String);
              final status = repair['status'] as String;
              final cost = repair['cost'] as double;
              final vehicle = repair['vehicle'] as String;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.only(top: 4, right: 8),
                      decoration: BoxDecoration(
                        color: Repair.getStatusColor(status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            description,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                vehicle,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('MMM d, yyyy').format(date),
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${NumberFormat('#,###.00').format(cost)} TND',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Repair.getStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            Repair.getStatusName(status),
                            style: TextStyle(
                              color: Repair.getStatusColor(status),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDataTable() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'All Repairs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    if (_startDate != null && _endDate != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                          label: Text(
                            '${DateFormat('dd MMM').format(_startDate!)} - ${DateFormat('dd MMM').format(_endDate!)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: _clearDateFilter,
                        ),
                      ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.date_range, size: 16),
                      label: const Text('Filter by Date'),
                      onPressed: _filterByDateRange,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Repair'),
                      onPressed: () {
                        _resetForm();
                        _showFormDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Search field
            TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by description, vehicle, or status',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadRepairs();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onChanged: (value) {
                if (value.isEmpty || value.length > 2) {
                  _loadRepairs();
                }
              },
            ),
            const SizedBox(height: 16),
            // Status filter buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedStatus == null,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedStatus = null;
                        _currentPage = 1;
                      });
                      _loadRepairs();
                    }
                  },
                ),
                ...Repair.getStatusOptions().map((status) {
                  return FilterChip(
                    label: Text(Repair.getStatusName(status)),
                    selected: _selectedStatus == status,
                    selectedColor: Repair.getStatusColor(status).withOpacity(0.2),
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = selected ? status : null;
                        _currentPage = 1;
                      });
                      _loadRepairs();
                    },
                  );
                }).toList(),
              ],
            ),
            const SizedBox(height: 16),
            // Data table
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                dataRowMinHeight: 60,
                dataRowMaxHeight: 60,
                columns: [
                  DataColumn(
                    label: const Text('ID'),
                    onSort: (_, __) => _toggleSort('id'),
                  ),
                  DataColumn(
                    label: Row(
                      children: [
                        const Text('Vehicle'),
                        const SizedBox(width: 4),
                        if (_sortBy == 'vehicle_brand')
                          Icon(
                            _sortAsc
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 16,
                          ),
                      ],
                    ),
                    onSort: (_, __) => _toggleSort('vehicle_brand'),
                  ),
                  DataColumn(
                    label: Row(
                      children: [
                        const Text('Description'),
                        const SizedBox(width: 4),
                        if (_sortBy == 'description')
                          Icon(
                            _sortAsc
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 16,
                          ),
                      ],
                    ),
                    onSort: (_, __) => _toggleSort('description'),
                  ),
                  DataColumn(
                    label: Row(
                      children: [
                        const Text('Date'),
                        const SizedBox(width: 4),
                        if (_sortBy == 'date')
                          Icon(
                            _sortAsc
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 16,
                          ),
                      ],
                    ),
                    onSort: (_, __) => _toggleSort('date'),
                  ),
                  DataColumn(
                    label: Row(
                      children: [
                        const Text('Cost'),
                        const SizedBox(width: 4),
                        if (_sortBy == 'cost')
                          Icon(
                            _sortAsc
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 16,
                          ),
                      ],
                    ),
                    onSort: (_, __) => _toggleSort('cost'),
                  ),
                  DataColumn(
                    label: Row(
                      children: [
                        const Text('Status'),
                        const SizedBox(width: 4),
                        if (_sortBy == 'status')
                          Icon(
                            _sortAsc
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 16,
                          ),
                      ],
                    ),
                    onSort: (_, __) => _toggleSort('status'),
                  ),
                  const DataColumn(
                    label: Text('Actions'),
                  ),
                ],
                rows: _repairs.map((repair) {
                  return DataRow(
                    cells: [
                      DataCell(Text('#${repair.id}')),
                      DataCell(
                        Tooltip(
                          message: 'Owner: ${_getCustomerName(repair.customerId)}',
                          child: Text(
                            '${repair.vehicleBrand} ${repair.vehicleModel}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        Tooltip(
                          message: repair.description,
                          child: Text(
                            repair.description,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(DateFormat('dd MMM yyyy').format(repair.date)),
                      ),
                      DataCell(
                        Text(
                          '${NumberFormat('#,###.00').format(repair.cost)} TND',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Repair.getStatusColor(repair.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            Repair.getStatusName(repair.status),
                            style: TextStyle(
                              color: Repair.getStatusColor(repair.status),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Status change menu
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.update, size: 18),
                              tooltip: 'Update Status',
                              itemBuilder: (context) {
                                return Repair.getStatusOptions()
                                    .where((status) => status != repair.status)
                                    .map((status) {
                                  return PopupMenuItem<String>(
                                    value: status,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Repair.getStatusColor(status),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(Repair.getStatusName(status)),
                                      ],
                                    ),
                                  );
                                }).toList();
                              },
                              onSelected: (status) => _updateStatus(repair, status),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              tooltip: 'Edit Repair',
                              onPressed: () => _editRepair(repair),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 18),
                              tooltip: 'Delete Repair',
                              onPressed: () => _deleteRepair(repair),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (!_isLoading && _repairs.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Text('No repairs found')),
              ),
            // Pagination
            if (!_isLoading && _repairs.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${(_currentPage - 1) * _perPage + 1}-${_currentPage * _perPage > _total ? _total : _currentPage * _perPage} of $_total',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: _currentPage > 1
                              ? () {
                                  setState(() {
                                    _currentPage--;
                                  });
                                  _loadRepairs();
                                }
                              : null,
                          tooltip: 'Previous Page',
                        ),
                        Text(
                          '$_currentPage / $_totalPages',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: _currentPage < _totalPages
                              ? () {
                                  setState(() {
                                    _currentPage++;
                                  });
                                  _loadRepairs();
                                }
                              : null,
                          tooltip: 'Next Page',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatistics() {
    if (_isStatisticsLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_statistics.isEmpty) {
      return const Center(child: Text('No data available'));
    }
    
    final totalRepairs = _statistics['total_repairs'] as int? ?? 0;
    final completedRepairs = _statistics['completed_repairs'] as int? ?? 0;
    final pendingRepairs = _statistics['pending_repairs'] as int? ?? 0;
    final totalRevenue = _statistics['total_revenue'] as double? ?? 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 16.0),
          child: Text(
            'Repair Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildStatisticsCard(
                'Total Repairs',
                totalRepairs.toString(),
                Icons.build,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatisticsCard(
                'Completed',
                completedRepairs.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatisticsCard(
                'Pending',
                pendingRepairs.toString(),
                Icons.pending_actions,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatisticsCard(
                'Total Revenue',
                '${NumberFormat('#,###.00').format(totalRevenue)} TND',
                Icons.attach_money,
                Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildStatusDistributionChart(),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: _buildRecentRepairsCard(),
            ),
          ],
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Repair Management',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Tab bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Repair List'),
              ],
              labelColor: Theme.of(context).primaryColor,
              indicatorColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
            ),
            
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Overview tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: _buildStatistics(),
                  ),
                  
                  // Repair list tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: _buildDataTable(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _resetForm();
          _showFormDialog();
        },
        tooltip: 'Add New Repair',
        child: const Icon(Icons.add),
      ),
    );
  }
}