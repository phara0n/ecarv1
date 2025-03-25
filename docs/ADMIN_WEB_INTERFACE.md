# eCar Garage Admin Web Interface

This document provides a comprehensive overview of the eCar Garage Admin Web Interface, built using Flutter Web, which allows garage staff to manage all aspects of the business.

## Overview

The Admin Web Interface serves as the central control panel for managing customers, vehicles, repairs, invoices, inventory, and staff. It provides intuitive dashboards and data management tools designed specifically for garage operations in Tunisia.

## Technologies Used

- **Flutter Web**: For cross-platform web development
- **Provider**: For state management
- **HTTP package**: For API communication
- **Chart libraries**: For data visualization (fl_chart)
- **PDF generation**: For creating and viewing invoice documents

## Getting Started

### Prerequisites

- Flutter SDK (version 3.7.0 or higher)
- Web browser (Chrome recommended for development)
- Backend API running (see API Documentation)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/phara0n/ecarv1.git
   cd ecarv1/frontend/web
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run for development:
   ```bash
   flutter run -d chrome
   ```

### Deployment Options

1. **Firebase Hosting**:
   ```bash
   flutter build web
   firebase init hosting
   firebase deploy
   ```

2. **Netlify**:
   ```bash
   flutter build web
   # Push to GitHub and connect Netlify
   ```

3. **Custom VPS (Ubuntu)**:
   ```bash
   flutter build web
   sudo apt-get install nginx
   sudo cp -r build/web/* /var/www/ecar-admin/
   # Configure Nginx
   ```

## Project Structure

```
lib/
├── main.dart               # Entry point
├── app.dart                # App configuration
├── config/                 # Environment config
├── models/                 # Data models
├── screens/                # UI screens
│   ├── auth/               # Authentication screens
│   ├── dashboard/          # Main dashboard
│   ├── customers/          # Customer management
│   ├── vehicles/           # Vehicle management
│   ├── repairs/            # Repair management
│   ├── invoices/           # Invoice management
│   ├── inventory/          # Parts inventory
│   ├── staff/              # Staff management
│   └── settings/           # App settings
├── services/               # API services
├── widgets/                # Reusable widgets
├── utils/                  # Helper functions
└── providers/              # State management
```

## Key Features

### Authentication System

- Secure login for admin staff with role-based permissions
- Password recovery functionality
- Session management with auto logout
- Activity logging for security audits

### Dashboard

The main dashboard provides:

- Daily overview of garage activity
- Metrics display (repairs in progress, completed repairs, revenue)
- Charts and graphs showing:
  - Monthly revenue trends
  - Vehicle brands distribution
  - Repair type distribution
  - Top services by volume

### Customer Management

- Complete customer database with search and filter capabilities
- Customer profile management
- Customer history and spending patterns
- Communication tools (SMS/email notifications)

### Vehicle Management

- Comprehensive vehicle database
- Service history for each vehicle
- Maintenance scheduling and alerts
- Vehicle documentation storage

### Repair Management

- Create and manage repair tickets
- Assign repairs to technicians
- Track repair status and progress
- Parts usage and inventory integration
- Time tracking for billing purposes

### Invoice Management

- Generate professional invoices
- Apply taxes and discounts
- Track payment status
- Export to PDF
- Email invoices directly to customers

### Inventory Management

- Track parts and supplies
- Low stock alerts
- Order management
- Supplier contact information
- Parts usage history and analytics

### Reporting

- Financial reports (daily, monthly, yearly)
- Technician performance metrics
- Vehicle type and repair statistics
- Revenue forecasting
- Export reports to CSV/PDF

## UI Design

The admin interface features a professional layout designed for efficient workflow:

1. **Navigation**: Responsive sidebar for easy access to all sections
2. **Data Tables**: Sortable and filterable tables for data management
3. **Dashboard Metrics**: Card-based information display
4. **Form Design**: Intuitive forms with validation
5. **Responsive Layout**: Functions well on desktops, tablets, and mobile devices

## Authentication and Security

The admin interface implements several security measures:

1. **JWT Authentication**: Secure token-based authentication
2. **Role-Based Access Control**: Different access levels for staff roles
3. **Input Validation**: Comprehensive validation to prevent security vulnerabilities
4. **Audit Logging**: All critical actions are logged for accountability
5. **Session Timeout**: Automatic logout after period of inactivity

## State Management

The application uses Provider for state management:

```dart
class RepairProvider with ChangeNotifier {
  List<Repair> _repairs = [];
  bool _loading = false;
  String? _error;
  
  List<Repair> get repairs => _repairs;
  bool get loading => _loading;
  String? get error => _error;
  
  Future<void> fetchRepairs() async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await RepairService().getRepairs();
      _repairs = response;
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> updateRepairStatus(int repairId, String status) async {
    try {
      await RepairService().updateStatus(repairId, status);
      // Update local state
      final index = _repairs.indexWhere((repair) => repair.id == repairId);
      if (index != -1) {
        _repairs[index] = _repairs[index].copyWith(status: status);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Other methods...
}
```

## Internationalization

The admin interface supports both English and Arabic languages:

```dart
MaterialApp(
  localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    AppLocalizations.delegate,
  ],
  supportedLocales: [
    Locale('en'), // English
    Locale('ar'), // Arabic
  ],
  locale: _locale, // Current locale based on user preference
)
```

## API Integration

Communication with the backend API is handled by service classes:

```dart
class InvoiceService {
  final String baseUrl = 'https://api.ecar.tn/api/v1';
  
  Future<List<Invoice>> getInvoices() async {
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/invoices'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Invoice.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load invoices');
    }
  }
  
  Future<void> generateInvoice(int repairId) async {
    final token = await AuthService().getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/invoices'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'repair_id': repairId,
      }),
    );
    
    if (response.statusCode != 201) {
      throw Exception('Failed to generate invoice');
    }
  }
  
  // Other API methods...
}
```

## Error Handling

The application implements comprehensive error handling:

1. **API Errors**: Properly catching and displaying API error messages
2. **Network Issues**: Handling offline scenarios and connection problems
3. **User Feedback**: Clear error messages and recovery options
4. **Logging**: Error logging for debugging purposes

Example error handling in a screen:

```dart
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Invoices')),
    body: Consumer<InvoiceProvider>(
      builder: (context, provider, child) {
        if (provider.loading) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${provider.error!}'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchInvoices(),
                  child: Text('Try Again'),
                ),
              ],
            ),
          );
        }
        
        // Regular UI
      },
    ),
  );
}
```

## PDF Generation

The admin interface can generate professional PDF invoices:

```dart
Future<Uint8List> generateInvoicePdf(Invoice invoice) async {
  final pdf = pw.Document();
  
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Header(
              level: 0,
              child: pw.Text('eCar Garage Invoice'),
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Invoice #${invoice.id}'),
                pw.Text('Date: ${DateFormat('yyyy-MM-dd').format(invoice.date)}'),
              ],
            ),
            // More invoice content...
          ],
        );
      },
    ),
  );
  
  return pdf.save();
}
```

## Future Enhancements

Planned features for future releases:

1. **Advanced Analytics Dashboard**: More detailed performance metrics
2. **Customer Mobile App Integration**: Direct status updates and communication
3. **Appointment Scheduling System**: Online booking system integration
4. **Vendor Management**: Expanded supplier relationship tools
5. **Automated SMS Notifications**: For repair status updates
6. **QR Code Integration**: For quick vehicle identification

## License

Proprietary software for eCar Garage. Unauthorized use, reproduction, or distribution is prohibited. 