import 'package:flutter/material.dart';

class CustomersScreenPart2 extends StatefulWidget {
  // ... (existing code)
  @override
  _CustomersScreenPart2State createState() => _CustomersScreenPart2State();
}

class _CustomersScreenPart2State extends State<CustomersScreenPart2> {
  // ... (existing code)

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
    // ... (existing code)
  }
} 