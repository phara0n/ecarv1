import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../models/vehicle.dart';
import '../models/customer.dart';
import '../services/vehicle_service.dart';
import '../services/customer_service.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/stat_card.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({Key? key}) : super(key: key);

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> with SingleTickerProviderStateMixin {
  final VehicleService _vehicleService = VehicleService();
  final CustomerService _customerService = CustomerService();
  late TabController _tabController;
  
  // Search and filter controllers
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // Vehicle form controllers
  final _customerIdController = TextEditingController();
  final _vinController = TextEditingController();
  final _colorController = TextEditingController();
  final _yearController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _mileageController = TextEditingController();
  final _lastServiceMileageController = TextEditingController();
  final _lastServiceDateController = TextEditingController();
  final _nextServiceDateController = TextEditingController();
  final _notesController = TextEditingController();
  final _modelController = TextEditingController();
  
  // State variables
  List<Vehicle> _vehicles = [];
  List<Customer> _customers = [];
  Map<String, dynamic> _statistics = {};
  int _currentPage = 1;
  int _totalPages = 1;
  int _perPage = 10;
  int _total = 0;
  bool _isLoadingVehicles = false;
  bool _isLoadingStats = false;
  bool _isFormLoading = false;
  bool _isEditing = false;
  int? _editingVehicleId;
  VehicleBrand? _selectedBrand;
  VehicleBrand? _filterBrand;
  int? _selectedCustomerId;
  int? _filterCustomerId;
  String? _sortBy = 'created_at';
  bool _sortAsc = false;
  DateTime? _selectedLastServiceDate;
  DateTime? _selectedNextServiceDate;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadVehicles();
    _loadCustomers();
    _loadStatistics();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _customerIdController.dispose();
    _vinController.dispose();
    _colorController.dispose();
    _yearController.dispose();
    _licensePlateController.dispose();
    _mileageController.dispose();
    _lastServiceMileageController.dispose();
    _lastServiceDateController.dispose();
    _nextServiceDateController.dispose();
    _notesController.dispose();
    _modelController.dispose();
    super.dispose();
  }
  
  Future<void> _loadVehicles() async {
    setState(() {
      _isLoadingVehicles = true;
    });
    
    try {
      final result = await _vehicleService.getVehicles(
        page: _currentPage,
        perPage: _perPage,
        search: _searchController.text.isEmpty ? null : _searchController.text,
        customerId: _filterCustomerId,
        brand: _filterBrand,
        sortBy: _sortBy,
        sortAsc: _sortAsc,
      );
      
      setState(() {
        _vehicles = result['vehicles'] as List<Vehicle>;
        _total = result['total'] as int;
        _currentPage = result['page'] as int;
        _perPage = result['per_page'] as int;
        _totalPages = result['total_pages'] as int;
        _isLoadingVehicles = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingVehicles = false;
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
  
  Future<void> _loadStatistics() async {
    setState(() {
      _isLoadingStats = true;
    });
    
    try {
      final stats = await _vehicleService.getVehicleStatistics();
      
      setState(() {
        _statistics = stats;
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingStats = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading statistics: $e')),
      );
    }
  }
  
  void _updateModelOptions(String brand) {
    setState(() {
      _selectedBrand = VehicleBrand(name: brand);
      _yearController.text = '';
    });
  }
  
  void _resetForm() {
    _customerIdController.clear();
    _vinController.clear();
    _colorController.clear();
    _yearController.clear();
    _licensePlateController.clear();
    _mileageController.clear();
    _lastServiceMileageController.clear();
    _lastServiceDateController.clear();
    _nextServiceDateController.clear();
    _notesController.clear();
    _modelController.clear();
    
    setState(() {
      _editingVehicleId = null;
      _isEditing = false;
      _selectedBrand = null;
      _selectedCustomerId = null;
      _selectedLastServiceDate = null;
      _selectedNextServiceDate = null;
    });
    
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
        'customer_id': _selectedCustomerId,
        'brand': _selectedBrand?.name,
        'model': _modelController.text,
        'license_plate': _licensePlateController.text,
        'year': int.parse(_yearController.text),
        'vin': _vinController.text.isEmpty ? null : _vinController.text,
        'color': _colorController.text.isEmpty ? null : _colorController.text,
        'current_mileage': int.parse(_mileageController.text),
        'last_service_mileage': int.parse(_lastServiceMileageController.text),
        'last_service_date': _selectedLastServiceDate?.toIso8601String(),
        'next_service_date': _selectedNextServiceDate?.toIso8601String(),
        'is_active': true,
        'notes': _notesController.text.isEmpty ? null : _notesController.text,
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
      
      // Refresh the data
      _resetForm();
      await _loadVehicles();
      await _loadStatistics();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving vehicle: $e')),
      );
    } finally {
      setState(() {
        _isFormLoading = false;
      });
    }
  }
  
  Future<void> _editVehicle(Vehicle vehicle) async {
    setState(() {
      _isEditing = true;
      _editingVehicleId = vehicle.id;
      _selectedCustomerId = vehicle.customerId;
      _selectedBrand = vehicle.brand;
      _customerIdController.text = vehicle.customerId.toString();
      _licensePlateController.text = vehicle.licensePlate;
      _yearController.text = vehicle.year.toString();
      _vinController.text = vehicle.vin ?? '';
      _colorController.text = vehicle.color ?? '';
      _mileageController.text = vehicle.currentMileage.toString();
      _lastServiceMileageController.text = vehicle.lastServiceMileage.toString();
      _selectedLastServiceDate = vehicle.lastServiceDate;
      _lastServiceDateController.text = vehicle.formattedLastServiceDate();
      _selectedNextServiceDate = vehicle.nextServiceDate;
      _nextServiceDateController.text = vehicle.formattedNextServiceDate();
      _notesController.text = vehicle.notes ?? '';
      _modelController.text = vehicle.model;
    });
    
    // Show the form dialog
    await _showVehicleForm();
  }
  
  Future<void> _deleteVehicle(Vehicle vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Are you sure you want to delete ${vehicle.getBrandDisplayName()} ${vehicle.model} (${vehicle.licensePlate})?'
        ),
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
      _isLoadingVehicles = true;
    });
    
    try {
      await _vehicleService.deleteVehicle(vehicle.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle deleted successfully')),
      );
      
      await _loadVehicles();
      await _loadStatistics();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting vehicle: $e')),
      );
    } finally {
      setState(() {
        _isLoadingVehicles = false;
      });
    }
  }
  
  Future<void> _toggleVehicleStatus(Vehicle vehicle) async {
    setState(() {
      _isLoadingVehicles = true;
    });
    
    try {
      await _vehicleService.toggleVehicleStatus(vehicle.id, !vehicle.isActive);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
          vehicle.isActive 
            ? 'Vehicle marked as inactive' 
            : 'Vehicle marked as active'
        )),
      );
      
      await _loadVehicles();
      await _loadStatistics();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating vehicle status: $e')),
      );
    } finally {
      setState(() {
        _isLoadingVehicles = false;
      });
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
            Text('${vehicle.getBrandDisplayName()} ${vehicle.model} (${vehicle.licensePlate})'),
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
      _isLoadingVehicles = true;
    });
    
    try {
      final mileage = int.parse(mileageController.text);
      await _vehicleService.updateMileage(vehicle.id, mileage);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mileage updated successfully')),
      );
      
      await _loadVehicles();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating mileage: $e')),
      );
    } finally {
      setState(() {
        _isLoadingVehicles = false;
      });
      mileageController.dispose();
    }
  }
  
  Future<void> _showVehicleForm() async {
    return showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dialog title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isEditing ? 'Edit Vehicle' : 'Add New Vehicle',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _resetForm();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Customer dropdown
                  DropdownButtonFormField<int>(
                    value: _selectedCustomerId,
                    decoration: const InputDecoration(
                      labelText: 'Customer',
                      hintText: 'Select a customer',
                      border: OutlineInputBorder(),
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
                  DropdownButtonFormField<VehicleBrand>(
                    value: _selectedBrand,
                    decoration: const InputDecoration(
                      labelText: 'Brand',
                      hintText: 'Select a brand',
                      border: OutlineInputBorder(),
                    ),
                    items: VehicleBrand.values.map((brand) {
                      final vehicle = Vehicle(
                        id: 0, 
                        customerId: 0, 
                        brand: brand, 
                        model: '', 
                        licensePlate: '', 
                        year: 2023, 
                        currentMileage: 0, 
                        lastServiceMileage: 0,
                        lastServiceDate: DateTime.now(),
                        isActive: true,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now()
                      );
                      return DropdownMenuItem<VehicleBrand>(
                        value: brand,
                        child: Row(
                          children: [
                            vehicle.getBrandLogo(size: 24),
                            const SizedBox(width: 8),
                            Text(vehicle.getBrandDisplayName()),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBrand = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a brand';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Model field
                  TextFormField(
                    controller: _modelController,
                    decoration: const InputDecoration(
                      labelText: 'Model',
                      hintText: 'Enter vehicle model',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the model';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Year field
                  TextFormField(
                    controller: _yearController,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      hintText: 'Enter vehicle year',
                      border: OutlineInputBorder(),
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
                  
                  // License Plate field
                  TextFormField(
                    controller: _licensePlateController,
                    decoration: const InputDecoration(
                      labelText: 'License Plate',
                      hintText: 'Enter license plate number',
                      border: OutlineInputBorder(),
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
                  
                  // Row for VIN and Color
                  Row(
                    children: [
                      // VIN field
                      Expanded(
                        child: TextFormField(
                          controller: _vinController,
                          decoration: const InputDecoration(
                            labelText: 'VIN (Optional)',
                            hintText: 'Enter VIN',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Color field
                      Expanded(
                        child: TextFormField(
                          controller: _colorController,
                          decoration: const InputDecoration(
                            labelText: 'Color (Optional)',
                            hintText: 'Enter color',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Row for mileage fields
                  Row(
                    children: [
                      // Current Mileage field
                      Expanded(
                        child: TextFormField(
                          controller: _mileageController,
                          decoration: const InputDecoration(
                            labelText: 'Current Mileage (km)',
                            hintText: 'Enter current mileage',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the mileage';
                            }
                            
                            final mileage = int.tryParse(value);
                            if (mileage == null || mileage < 0) {
                              return 'Invalid mileage';
                            }
                            
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Last Service Mileage field
                      Expanded(
                        child: TextFormField(
                          controller: _lastServiceMileageController,
                          decoration: const InputDecoration(
                            labelText: 'Last Service Mileage',
                            hintText: 'Enter last service mileage',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the last service mileage';
                            }
                            
                            final mileage = int.tryParse(value);
                            if (mileage == null || mileage < 0) {
                              return 'Invalid mileage';
                            }
                            
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Row for service date fields
                  Row(
                    children: [
                      // Last Service Date field
                      Expanded(
                        child: TextFormField(
                          controller: _lastServiceDateController,
                          decoration: InputDecoration(
                            labelText: 'Last Service Date',
                            hintText: 'Select last service date',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedLastServiceDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                
                                if (date != null) {
                                  setState(() {
                                    _selectedLastServiceDate = date;
                                    _lastServiceDateController.text = DateFormat('MMM d, yyyy').format(date);
                                  });
                                }
                              },
                            ),
                          ),
                          readOnly: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select the last service date';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Next Service Date field
                      Expanded(
                        child: TextFormField(
                          controller: _nextServiceDateController,
                          decoration: InputDecoration(
                            labelText: 'Next Service Date (Optional)',
                            hintText: 'Select next service date',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedNextServiceDate ?? DateTime.now().add(const Duration(days: 180)),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 730)),
                                );
                                
                                if (date != null) {
                                  setState(() {
                                    _selectedNextServiceDate = date;
                                    _nextServiceDateController.text = DateFormat('MMM d, yyyy').format(date);
                                  });
                                }
                              },
                            ),
                          ),
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Notes field
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      hintText: 'Enter any notes about this vehicle',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  
                  // Submit button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          _resetForm();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
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
                ],
              ),
            ),
          ),
        ),
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
  
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  
  // Build the overview tab
  Widget _buildOverviewTab() {
    if (_isLoadingStats) {
      return const Center(child: LoadingIndicator());
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics cards
          Text(
            'Vehicle Statistics',
            style: Theme.of(context).textTheme.headline6,
          ),
          const SizedBox(height: 16),
          
          // Statistics cards row
          ResponsiveRowColumn(
            rowMainAxisAlignment: MainAxisAlignment.spaceBetween,
            rowPadding: const EdgeInsets.symmetric(horizontal: 8),
            layout: ResponsiveBreakpoints.of(context).largerThan(MOBILE) 
                ? ResponsiveRowColumnType.ROW
                : ResponsiveRowColumnType.COLUMN,
            children: [
              // Total vehicles card
              ResponsiveRowColumnItem(
                rowFlex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StatCard(
                    title: 'Total Vehicles',
                    value: '${_statistics['total_vehicles'] ?? 0}',
                    icon: Icons.directions_car,
                    color: Colors.blue,
                    onTap: () {
                      _tabController.animateTo(1);
                      setState(() {
                        _filterBrand = null;
                        _filterCustomerId = null;
                      });
                      _loadVehicles();
                    },
                  ),
                ),
              ),
              
              // Active vehicles card
              ResponsiveRowColumnItem(
                rowFlex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StatCard(
                    title: 'Active Vehicles',
                    value: '${_statistics['active_vehicles'] ?? 0}',
                    icon: Icons.check_circle,
                    color: Colors.green,
                    onTap: () {
                      _tabController.animateTo(1);
                      _loadVehicles();
                    },
                  ),
                ),
              ),
              
              // Service due card
              ResponsiveRowColumnItem(
                rowFlex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StatCard(
                    title: 'Service Due',
                    value: '${_statistics['service_due_count'] ?? 0}',
                    icon: Icons.warning,
                    color: Colors.orange,
                    onTap: () {
                      _tabController.animateTo(1);
                      _loadVehicles();
                    },
                  ),
                ),
              ),
              
              // Service overdue card
              ResponsiveRowColumnItem(
                rowFlex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StatCard(
                    title: 'Service Overdue',
                    value: '${_statistics['service_overdue_count'] ?? 0}',
                    icon: Icons.error,
                    color: Colors.red,
                    onTap: () {
                      _tabController.animateTo(1);
                      _loadVehicles();
                    },
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Charts section
          ResponsiveRowColumn(
            layout: ResponsiveBreakpoints.of(context).largerThan(MOBILE) 
                ? ResponsiveRowColumnType.ROW
                : ResponsiveRowColumnType.COLUMN,
            children: [
              // Brand distribution chart
              ResponsiveRowColumnItem(
                rowFlex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Vehicles by Brand',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 300,
                            child: _buildBrandPieChart(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Vehicle age chart
              ResponsiveRowColumnItem(
                rowFlex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Vehicles by Year',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 300,
                            child: _buildYearBarChart(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Service history chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Service History',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: _buildServiceHistoryChart(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Recent services table
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Services',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRecentServicesTable(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Build the brand distribution pie chart
  Widget _buildBrandPieChart() {
    final brandData = _statistics['by_brand'] as Map<String, dynamic>? ?? {};
    
    if (brandData.isEmpty) {
      return const Center(child: Text('No data available'));
    }
    
    final pieChartSections = <PieChartSectionData>[];
    final colors = [
      const Color(0xFF0066B1), // BMW Blue
      const Color(0xFF9A9A9A), // Mercedes Silver
      const Color(0xFF003399), // VW Blue
      const Color(0xFF000000), // Audi Black
      const Color(0xFFEB0A1E), // Toyota Red
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];
    
    int i = 0;
    brandData.forEach((brand, count) {
      pieChartSections.add(
        PieChartSectionData(
          color: colors[i % colors.length],
          value: (count as int).toDouble(),
          title: brand,
          radius: 120,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      i++;
    });
    
    return PieChart(
      PieChartData(
        sections: pieChartSections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }
  
  // Build the year distribution bar chart
  Widget _buildYearBarChart() {
    final yearData = _statistics['by_year'] as Map<String, dynamic>? ?? {};
    
    if (yearData.isEmpty) {
      return const Center(child: Text('No data available'));
    }
    
    final items = yearData.entries.toList();
    final barGroups = <BarChartGroupData>[];
    final titles = <String>[];
    
    for (int i = 0; i < items.length; i++) {
      final entry = items[i];
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
        maxY: (yearData.values.map((v) => v as int).toList()..sort()).last * 1.2,
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
                  child: Text(titles[value.toInt()]),
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
  
  // Build the service history line chart
  Widget _buildServiceHistoryChart() {
    final serviceHistory = _statistics['service_history'] as Map<String, dynamic>? ?? {};
    
    if (serviceHistory.isEmpty) {
      return const Center(child: Text('No data available'));
    }
    
    final spots = <FlSpot>[];
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    for (int i = 0; i < months.length; i++) {
      final month = months[i];
      final count = serviceHistory[month] as int? ?? 0;
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
  
  // Build the recent services table
  Widget _buildRecentServicesTable() {
    final recentServices = _statistics['recent_services'] as List<dynamic>? ?? [];
    
    if (recentServices.isEmpty) {
      return const Center(child: Text('No recent services'));
    }
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('License Plate')),
          DataColumn(label: Text('Brand')),
          DataColumn(label: Text('Model')),
          DataColumn(label: Text('Customer')),
          DataColumn(label: Text('Service Date')),
          DataColumn(label: Text('Mileage')),
        ],
        rows: recentServices.map<DataRow>((service) {
          return DataRow(
            cells: [
              DataCell(Text(service['license_plate'] as String)),
              DataCell(Text(service['brand'] as String)),
              DataCell(Text(service['model'] as String)),
              DataCell(Text(service['customer_name'] as String)),
              DataCell(Text(DateFormat('MMM d, yyyy').format(
                DateTime.parse(service['service_date'] as String),
              ))),
              DataCell(Text('${NumberFormat('#,###').format(service['mileage'])} km')),
            ],
          );
        }).toList(),
      ),
    );
  }
  
  // Build the vehicle list tab
  Widget _buildVehicleListTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search and filters
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Search field
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
              
              // Add vehicle button
              ElevatedButton.icon(
                onPressed: () async {
                  _resetForm();
                  await _showVehicleForm();
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
        
        // Filter row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              // Brand filter
              Expanded(
                child: DropdownButtonFormField<VehicleBrand?>(
                  value: _filterBrand,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Brand',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<VehicleBrand?>(
                      value: null,
                      child: Text('All Brands'),
                    ),
                    ...VehicleBrand.values.map((brand) {
                      final vehicle = Vehicle(
                        id: 0, 
                        customerId: 0, 
                        brand: brand, 
                        model: '', 
                        licensePlate: '', 
                        year: 2023, 
                        currentMileage: 0, 
                        lastServiceMileage: 0,
                        lastServiceDate: DateTime.now(),
                        isActive: true,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now()
                      );
                      return DropdownMenuItem<VehicleBrand?>(
                        value: brand,
                        child: Row(
                          children: [
                            vehicle.getBrandLogo(size: 16),
                            const SizedBox(width: 8),
                            Text(vehicle.getBrandDisplayName()),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                  onChanged: (brand) {
                    setState(() {
                      _filterBrand = brand;
                      _currentPage = 1;
                    });
                    _loadVehicles();
                  },
                ),
              ),
              const SizedBox(width: 16),
              
              // Customer filter
              Expanded(
                child: DropdownButtonFormField<int?>(
                  value: _filterCustomerId,
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
                      _filterCustomerId = value;
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
                    _filterBrand = null;
                    _filterCustomerId = null;
                    _searchController.clear();
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
        
        // Vehicle data table
        Expanded(
          child: _isLoadingVehicles
              ? const Center(child: LoadingIndicator())
              : _vehicles.isEmpty
                  ? const Center(
                      child: Text('No vehicles found'),
                    )
                  : _buildVehiclesDataTable(),
        ),
        
        // Pagination controls
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
    );
  }
  
  // Build the vehicles data table
  Widget _buildVehiclesDataTable() {
    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 900,
      sortColumnIndex: _sortBy == 'id' ? 0 : 
                      _sortBy == 'brand' ? 1 :
                      _sortBy == 'model' ? 2 :
                      _sortBy == 'year' ? 3 :
                      _sortBy == 'license_plate' ? 4 :
                      _sortBy == 'current_mileage' ? 6 :
                      _sortBy == 'created_at' ? 7 : null,
      sortAscending: _sortAsc,
      columns: [
        DataColumn2(
          label: const Text('ID'),
          onSort: (_, __) => _toggleSort('id'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: const Text('Brand'),
          onSort: (_, __) => _toggleSort('brand'),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: const Text('Model'),
          onSort: (_, __) => _toggleSort('model'),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: const Text('Year'),
          onSort: (_, __) => _toggleSort('year'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: const Text('License Plate'),
          onSort: (_, __) => _toggleSort('license_plate'),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: const Text('Customer'),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: const Text('Mileage'),
          onSort: (_, __) => _toggleSort('current_mileage'),
          size: ColumnSize.M,
          numeric: true,
        ),
        DataColumn2(
          label: const Text('Service Status'),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: const Text('Actions'),
          size: ColumnSize.L,
        ),
      ],
      rows: _vehicles.map((vehicle) {
        return DataRow2(
          cells: [
            DataCell(Text('#${vehicle.id}')),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  vehicle.getBrandLogo(size: 20),
                  const SizedBox(width: 8),
                  Text(vehicle.getBrandDisplayName()),
                ],
              ),
            ),
            DataCell(Text(vehicle.model)),
            DataCell(Text(vehicle.year.toString())),
            DataCell(Text(vehicle.licensePlate)),
            DataCell(Text(vehicle.customerName ?? _getCustomerName(vehicle.customerId))),
            DataCell(Text(vehicle.formattedMileage())),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: vehicle.getServiceStatusColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  vehicle.getServiceStatusText(),
                  style: TextStyle(
                    color: vehicle.getServiceStatusColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _editVehicle(vehicle),
                    tooltip: 'Edit Vehicle',
                  ),
                  IconButton(
                    icon: Icon(
                      vehicle.isActive ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                      color: vehicle.isActive ? Colors.red : Colors.green,
                    ),
                    onPressed: () => _toggleVehicleStatus(vehicle),
                    tooltip: vehicle.isActive ? 'Mark as Inactive' : 'Mark as Active',
                  ),
                  IconButton(
                    icon: const Icon(Icons.speed, size: 20, color: Colors.orange),
                    onPressed: () => _updateMileage(vehicle),
                    tooltip: 'Update Mileage',
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    tooltip: 'More Actions',
                    onSelected: (action) {
                      switch (action) {
                        case 'repairs':
                          _showSnackBar('View repairs would be implemented here');
                          break;
                        case 'history':
                          _showSnackBar('View history would be implemented here');
                          break;
                        case 'delete':
                          _deleteVehicle(vehicle);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: 'repairs',
                        child: ListTile(
                          leading: Icon(Icons.build),
                          title: Text('View Repairs'),
                          dense: true,
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'history',
                        child: ListTile(
                          leading: Icon(Icons.history),
                          title: Text('Service History'),
                          dense: true,
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Delete Vehicle'),
                          dense: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Management'),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Vehicle List'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_tabController.index == 0) {
                _loadStatistics();
              } else {
                _loadVehicles();
              }
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildVehicleListTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              onPressed: () async {
                _resetForm();
                await _showVehicleForm();
              },
              tooltip: 'Add Vehicle',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}