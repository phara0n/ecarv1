import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:data_table_2/data_table_2.dart';
import '../models/invoice.dart';
import '../services/invoice_service.dart';
import '../widgets/stat_card.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({Key? key}) : super(key: key);

  @override
  _InvoicesScreenState createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final InvoiceService _invoiceService = InvoiceService();
  
  // State for the invoice overview
  bool _isLoadingStats = true;
  Map<String, dynamic> _statistics = {};
  
  // State for the invoice list
  bool _isLoadingInvoices = true;
  List<Invoice> _invoices = [];
  int _totalInvoices = 0;
  int _currentPage = 1;
  int _perPage = 10;
  int _totalPages = 1;
  String? _searchQuery;
  String? _selectedStatus;
  String? _sortBy = 'issue_date';
  bool _sortAsc = false;
  DateTime? _startDate;
  DateTime? _endDate;
  
  // Selected invoice for actions
  Invoice? _selectedInvoice;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStatistics();
    _loadInvoices();
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
      final stats = await _invoiceService.getInvoiceStatistics();
      setState(() {
        _statistics = stats;
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingStats = false;
      });
      _showSnackBar('Failed to load invoice statistics: ${e.toString()}');
    }
  }
  
  // Load invoices for the list tab
  Future<void> _loadInvoices() async {
    setState(() {
      _isLoadingInvoices = true;
    });
    
    try {
      final result = await _invoiceService.getInvoices(
        page: _currentPage,
        perPage: _perPage,
        search: _searchQuery,
        status: _selectedStatus,
        startDate: _startDate,
        endDate: _endDate,
        sortBy: _sortBy,
        sortAsc: _sortAsc,
      );
      
      setState(() {
        _invoices = result['invoices'] as List<Invoice>;
        _totalInvoices = result['total'] as int;
        _currentPage = result['page'] as int;
        _perPage = result['per_page'] as int;
        _totalPages = result['total_pages'] as int;
        _isLoadingInvoices = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingInvoices = false;
      });
      _showSnackBar('Failed to load invoices: ${e.toString()}');
    }
  }
  
  // Change page
  void _changePage(int page) {
    if (page != _currentPage) {
      setState(() {
        _currentPage = page;
      });
      _loadInvoices();
    }
  }
  
  // Apply filters
  void _applyFilters() {
    setState(() {
      _currentPage = 1;
    });
    _loadInvoices();
  }
  
  // Reset filters
  void _resetFilters() {
    setState(() {
      _searchQuery = null;
      _selectedStatus = null;
      _startDate = null;
      _endDate = null;
      _currentPage = 1;
    });
    _loadInvoices();
  }
  
  // Sort invoices
  void _sortInvoices(String column) {
    setState(() {
      if (_sortBy == column) {
        _sortAsc = !_sortAsc;
      } else {
        _sortBy = column;
        _sortAsc = true;
      }
    });
    _loadInvoices();
  }
  
  // Show a form dialog to add/edit an invoice
  Future<void> _showInvoiceForm({Invoice? invoice}) async {
    // This would be implemented with a form to add/edit invoice
    // For brevity, this is a placeholder
    _showSnackBar('Invoice form would be shown here');
  }
  
  // Delete an invoice
  Future<void> _deleteInvoice(Invoice invoice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete invoice ${invoice.invoiceNumber}?'),
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
        await _invoiceService.deleteInvoice(invoice.id);
        _showSnackBar('Invoice deleted successfully');
        _loadInvoices();
        _loadStatistics();
      } catch (e) {
        _showSnackBar('Failed to delete invoice: ${e.toString()}');
      }
    }
  }
  
  // Update invoice status
  Future<void> _updateStatus(Invoice invoice, String newStatus) async {
    try {
      await _invoiceService.updateStatus(invoice.id, newStatus);
      _showSnackBar('Status updated successfully');
      _loadInvoices();
      _loadStatistics();
    } catch (e) {
      _showSnackBar('Failed to update status: ${e.toString()}');
    }
  }
  
  // Generate PDF for an invoice
  Future<void> _generatePdf(Invoice invoice) async {
    try {
      final pdfUrl = await _invoiceService.generatePdf(invoice.id);
      // Here you would open the PDF in a new tab or download it
      _showSnackBar('PDF generated successfully');
    } catch (e) {
      _showSnackBar('Failed to generate PDF: ${e.toString()}');
    }
  }
  
  // Send invoice by email
  Future<void> _sendByEmail(Invoice invoice) async {
    final emailController = TextEditingController(
      text: '', // Would typically pre-fill with customer email if available
    );
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Invoice by Email'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            hintText: 'Enter recipient email',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Send'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && emailController.text.isNotEmpty) {
      try {
        await _invoiceService.sendByEmail(invoice.id, emailController.text);
        _showSnackBar('Invoice sent successfully');
      } catch (e) {
        _showSnackBar('Failed to send invoice: ${e.toString()}');
      }
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
        title: const Text('Invoice Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Invoice List'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildInvoiceListTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showInvoiceForm(),
        child: const Icon(Icons.add),
        tooltip: 'Create New Invoice',
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
            'Invoice Statistics',
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
                title: 'Total Invoices',
                value: _statistics['total_invoices']?.toString() ?? '0',
                icon: Icons.receipt_long,
                color: Colors.blue,
              ),
              StatCard(
                title: 'Total Amount',
                value: currencyFormat.format(_statistics['total_amount'] ?? 0),
                icon: Icons.attach_money,
                color: Colors.green,
              ),
              StatCard(
                title: 'Pending Invoices',
                value: _statistics['total_pending']?.toString() ?? '0',
                icon: Icons.pending_actions,
                color: Colors.orange,
              ),
              StatCard(
                title: 'Overdue Invoices',
                value: _statistics['total_overdue']?.toString() ?? '0',
                icon: Icons.warning_amber,
                color: Colors.red,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Status distribution chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Invoice Status Distribution',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: _buildStatusDistributionChart(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Monthly revenue chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Revenue',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: _buildMonthlyRevenueChart(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Recent invoices card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Invoices',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildRecentInvoicesTable(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Build the invoice list tab
  Widget _buildInvoiceListTab() {
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
                            hintText: 'Invoice number, customer name...',
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
                      DropdownButton<String>(
                        hint: const Text('Status'),
                        value: _selectedStatus,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Statuses'),
                          ),
                          ...Invoice.getStatusOptions().map((status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(Invoice.getStatusName(status)),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      TextButton.icon(
                        icon: const Icon(Icons.date_range),
                        label: const Text('Date Range'),
                        onPressed: () async {
                          final dateRange = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          
                          if (dateRange != null) {
                            setState(() {
                              _startDate = dateRange.start;
                              _endDate = dateRange.end;
                            });
                          }
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
        
        // Invoice data table
        Expanded(
          child: _isLoadingInvoices
              ? const Center(child: CircularProgressIndicator())
              : _buildInvoicesDataTable(),
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
  
  // Build the status distribution chart
  Widget _buildStatusDistributionChart() {
    final statusData = _statistics['status_distribution'] as Map<String, dynamic>? ?? {};
    
    final pieChartSections = <PieChartSectionData>[];
    
    if (statusData.isNotEmpty) {
      final statuses = ['paid', 'pending', 'overdue', 'cancelled'];
      final colors = [Colors.green, Colors.orange, Colors.red, Colors.grey];
      
      for (int i = 0; i < statuses.length; i++) {
        final status = statuses[i];
        final count = statusData[status] as int? ?? 0;
        
        if (count > 0) {
          pieChartSections.add(
            PieChartSectionData(
              color: colors[i],
              value: count.toDouble(),
              title: '${Invoice.getStatusName(status)}\n$count',
              radius: 120,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );
        }
      }
    }
    
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
  
  // Build the monthly revenue chart
  Widget _buildMonthlyRevenueChart() {
    final monthlyRevenue = _statistics['monthly_revenue'] as Map<String, dynamic>? ?? {};
    
    if (monthlyRevenue.isEmpty) {
      return const Center(child: Text('No data available'));
    }
    
    final spots = <FlSpot>[];
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    for (int i = 0; i < months.length; i++) {
      final month = months[i];
      final amount = monthlyRevenue[month] as double? ?? 0.0;
      spots.add(FlSpot(i.toDouble(), amount));
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
                  NumberFormat.compact().format(value),
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
            color: Colors.blue,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
  
  // Build the recent invoices table
  Widget _buildRecentInvoicesTable() {
    final recentInvoices = _statistics['recent_invoices'] as List<dynamic>? ?? [];
    
    if (recentInvoices.isEmpty) {
      return const Center(child: Text('No recent invoices'));
    }
    
    return DataTable(
      columns: const [
        DataColumn(label: Text('Invoice #')),
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Customer')),
        DataColumn(label: Text('Vehicle')),
        DataColumn(label: Text('Amount')),
        DataColumn(label: Text('Status')),
      ],
      rows: recentInvoices.map<DataRow>((invoice) {
        final status = invoice['status'] as String;
        return DataRow(
          cells: [
            DataCell(Text(invoice['invoice_number'] as String)),
            DataCell(Text(DateFormat('MMM d, yyyy').format(
              DateTime.parse(invoice['issue_date'] as String),
            ))),
            DataCell(Text(invoice['customer_name'] as String)),
            DataCell(Text(invoice['vehicle'] as String)),
            DataCell(Text(
              NumberFormat.currency(symbol: 'TND ').format(invoice['total'] as double),
            )),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Invoice.getStatusColor(status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  Invoice.getStatusName(status),
                  style: TextStyle(
                    color: Invoice.getStatusColor(status),
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
  
  // Build the invoices data table
  Widget _buildInvoicesDataTable() {
    if (_invoices.isEmpty) {
      return const Center(
        child: Text('No invoices found matching your criteria'),
      );
    }
    
    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 900,
      sortColumnIndex: _sortBy == 'invoice_number' ? 0 : 
                      _sortBy == 'issue_date' ? 1 :
                      _sortBy == 'due_date' ? 2 :
                      _sortBy == 'total' ? 5 : null,
      sortAscending: _sortAsc,
      columns: [
        DataColumn2(
          label: const Text('Invoice #'),
          onSort: (_, __) => _sortInvoices('invoice_number'),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: const Text('Issue Date'),
          onSort: (_, __) => _sortInvoices('issue_date'),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: const Text('Due Date'),
          onSort: (_, __) => _sortInvoices('due_date'),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: const Text('Customer'),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: const Text('Vehicle'),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: const Text('Total'),
          onSort: (_, __) => _sortInvoices('total'),
          numeric: true,
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: const Text('Status'),
          size: ColumnSize.M,
        ),
        const DataColumn2(
          label: Text('Actions'),
          size: ColumnSize.L,
        ),
      ],
      rows: _invoices.map((invoice) {
        return DataRow2(
          cells: [
            DataCell(Text(invoice.invoiceNumber)),
            DataCell(Text(DateFormat('MMM d, yyyy').format(invoice.issueDate))),
            DataCell(Text(DateFormat('MMM d, yyyy').format(invoice.dueDate))),
            DataCell(Text(invoice.customerName ?? 'N/A')),
            DataCell(Text('${invoice.vehicleBrand ?? ''} ${invoice.vehicleModel ?? ''}'.trim())),
            DataCell(Text(
              NumberFormat.currency(symbol: 'TND ').format(invoice.total),
            )),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Invoice.getStatusColor(invoice.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  Invoice.getStatusName(invoice.status),
                  style: TextStyle(
                    color: Invoice.getStatusColor(invoice.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            DataCell(Row(
              children: [
                // Edit button
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  tooltip: 'Edit Invoice',
                  onPressed: () => _showInvoiceForm(invoice: invoice),
                ),
                // Status dropdown
                PopupMenuButton<String>(
                  tooltip: 'Update Status',
                  icon: const Icon(Icons.update, size: 20),
                  onSelected: (String newStatus) => _updateStatus(invoice, newStatus),
                  itemBuilder: (context) => Invoice.getStatusOptions()
                      .map((status) => PopupMenuItem<String>(
                            value: status,
                            child: Text(Invoice.getStatusName(status)),
                          ))
                      .toList(),
                ),
                // More actions dropdown
                PopupMenuButton<String>(
                  tooltip: 'More Actions',
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (String action) {
                    switch (action) {
                      case 'pdf':
                        _generatePdf(invoice);
                        break;
                      case 'email':
                        _sendByEmail(invoice);
                        break;
                      case 'delete':
                        _deleteInvoice(invoice);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'pdf',
                      child: ListTile(
                        leading: Icon(Icons.picture_as_pdf),
                        title: Text('Generate PDF'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'email',
                      child: ListTile(
                        leading: Icon(Icons.email),
                        title: Text('Send by Email'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Delete Invoice'),
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