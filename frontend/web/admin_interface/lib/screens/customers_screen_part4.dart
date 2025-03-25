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