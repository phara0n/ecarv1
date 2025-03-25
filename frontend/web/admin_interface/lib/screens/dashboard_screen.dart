import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'customers_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isSidebarCollapsed = false;
  
  final List<Map<String, dynamic>> _navItems = [
    {
      'icon': Icons.dashboard,
      'label': 'Dashboard',
      'screen': const DashboardOverview(),
    },
    {
      'icon': Icons.people,
      'label': 'Customers',
      'screen': const CustomersScreen(),
    },
    {
      'icon': Icons.directions_car,
      'label': 'Vehicles',
      'screen': const Center(child: Text('Vehicles Screen - Coming Soon')),
    },
    {
      'icon': Icons.build,
      'label': 'Repairs',
      'screen': const Center(child: Text('Repairs Screen - Coming Soon')),
    },
    {
      'icon': Icons.receipt,
      'label': 'Invoices',
      'screen': const Center(child: Text('Invoices Screen - Coming Soon')),
    },
    {
      'icon': Icons.settings,
      'label': 'Settings',
      'screen': const Center(child: Text('Settings Screen - Coming Soon')),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isDesktop = ResponsiveBreakpoints.of(context).isDesktop || size.width > 900;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('eCar Garage Admin'),
        leading: isDesktop
            ? IconButton(
                icon: Icon(
                  _isSidebarCollapsed ? Icons.menu : Icons.menu_open,
                ),
                onPressed: () {
                  setState(() {
                    _isSidebarCollapsed = !_isSidebarCollapsed;
                  });
                },
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              color: Colors.black,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: isDesktop ? null : _buildSidebar(),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(),
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: _navItems[_selectedIndex]['screen'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    final bool isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
    
    return SizedBox(
      width: isDesktop && _isSidebarCollapsed ? 70 : 250,
      child: Drawer(
        elevation: isDesktop ? 0 : 2,
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              if (!isDesktop) ...[
                Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Center(
                            child: Text(
                              'eCar',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Admin Panel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
              ],
              Expanded(
                child: ListView.builder(
                  itemCount: _navItems.length,
                  itemBuilder: (context, index) {
                    final item = _navItems[index];
                    final isSelected = _selectedIndex == index;
                    
                    return ListTile(
                      selected: isSelected,
                      selectedTileColor: Colors.grey[200],
                      leading: Icon(
                        item['icon'],
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[700],
                      ),
                      title: isDesktop && _isSidebarCollapsed
                          ? null
                          : Text(
                              item['label'],
                              style: TextStyle(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[700],
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                        
                        if (!isDesktop) {
                          Navigator.pop(context);
                        }
                      },
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: isDesktop && _isSidebarCollapsed
                    ? null
                    : const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                onTap: () {
                  // Show a confirmation dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout Confirmation'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardOverview extends StatelessWidget {
  const DashboardOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Title
          const Text(
            'Dashboard Overview',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Stats Cards
          _buildStatsGrid(context),
          const SizedBox(height: 24),
          
          // Recent Activity and Upcoming Services
          _buildRecentActivity(context),
          const SizedBox(height: 24),
          
          // Vehicle Brand Distribution
          _buildBrandDistribution(context),
        ],
      ),
    );
  }
  
  Widget _buildStatsGrid(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    
    return GridView.count(
      crossAxisCount: isMobile ? 1 : 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          context,
          'Total Customers',
          '128',
          Icons.people,
          Colors.blue,
        ),
        _buildStatCard(
          context,
          'Active Repairs',
          '42',
          Icons.build,
          Colors.orange,
        ),
        _buildStatCard(
          context,
          'Completed This Month',
          '87',
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          context,
          'Total Revenue',
          'TND 56,230',
          Icons.attach_money,
          Colors.purple,
        ),
      ],
    );
  }
  
  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const Spacer(),
                Icon(
                  Icons.more_vert,
                  color: Colors.grey[400],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentActivity(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Card(
            elevation: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final activities = [
                      {
                        'title': 'New repair created',
                        'subtitle': 'BMW X5 - Oil Change',
                        'time': '10 minutes ago',
                      },
                      {
                        'title': 'Invoice generated',
                        'subtitle': 'Mercedes C-Class - Annual Service',
                        'time': '2 hours ago',
                      },
                      {
                        'title': 'Repair status updated',
                        'subtitle': 'Audi A4 - Brake Replacement',
                        'time': '3 hours ago',
                      },
                      {
                        'title': 'New customer added',
                        'subtitle': 'Ahmed Ben Ali',
                        'time': '5 hours ago',
                      },
                      {
                        'title': 'Payment received',
                        'subtitle': 'Invoice #2023-156',
                        'time': '6 hours ago',
                      },
                    ];
                    
                    final activity = activities[index];
                    
                    return ListTile(
                      title: Text(activity['title']!),
                      subtitle: Text(activity['subtitle']!),
                      trailing: Text(
                        activity['time']!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Card(
            elevation: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Upcoming Services',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final services = [
                      {
                        'title': 'Volkswagen Golf',
                        'service': 'Oil Change',
                        'date': 'Tomorrow, 10:00 AM',
                      },
                      {
                        'title': 'BMW 3 Series',
                        'service': 'Brake Inspection',
                        'date': 'In 2 days, 2:30 PM',
                      },
                      {
                        'title': 'Mercedes GLC',
                        'service': 'Annual Service',
                        'date': 'In 3 days, 9:00 AM',
                      },
                    ];
                    
                    final service = services[index];
                    
                    return ListTile(
                      title: Text(service['title']!),
                      subtitle: Text(service['service']!),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          service['date']!,
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildBrandDistribution(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vehicle Brand Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            isMobile
                ? Column(
                    children: [
                      _buildBrandProgressBar(context, 'BMW', 0.3, const Color(0xFF0066B1)),
                      _buildBrandProgressBar(context, 'Mercedes', 0.25, const Color(0xFF9A9A9A)),
                      _buildBrandProgressBar(context, 'Volkswagen', 0.2, const Color(0xFF003399)),
                      _buildBrandProgressBar(context, 'Other', 0.25, Colors.grey),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: _buildBrandProgressBar(context, 'BMW', 0.3, const Color(0xFF0066B1))),
                      Expanded(child: _buildBrandProgressBar(context, 'Mercedes', 0.25, const Color(0xFF9A9A9A))),
                      Expanded(child: _buildBrandProgressBar(context, 'Volkswagen', 0.2, const Color(0xFF003399))),
                      Expanded(child: _buildBrandProgressBar(context, 'Other', 0.25, Colors.grey)),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBrandProgressBar(
    BuildContext context,
    String brand,
    double percentage,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                brand,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('${(percentage * 100).toInt()}%'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ],
      ),
    );
  }
} 