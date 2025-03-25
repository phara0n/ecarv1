# eCar Garage Mobile App Developer Guide

This document serves as a comprehensive guide for developers working on the eCar Garage Mobile application built with Flutter.

## Getting Started

### Prerequisites

- Flutter SDK (version 3.7.0 or higher)
- Dart SDK (version 2.19.0 or higher)
- Android Studio or VS Code with Flutter plugins
- An emulator or physical device for testing

### Project Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/phara0n/ecarv1.git
   cd ecarv1/frontend/mobile
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart               # Entry point
├── app.dart                # App configuration
├── config/                 # Environment config
├── models/                 # Data models
├── screens/                # UI screens
├── services/               # API services
├── widgets/                # Reusable widgets
├── utils/                  # Helper functions
└── providers/              # State management
```

## Key Components

### State Management

The application uses Provider for state management. Each major feature has its own provider:

- `AuthProvider`: Manages user authentication state
- `VehicleProvider`: Manages vehicle data
- `RepairProvider`: Manages repair history
- `InvoiceProvider`: Manages invoice data

Example provider implementation:

```dart
class VehicleProvider with ChangeNotifier {
  List<Vehicle> _vehicles = [];
  bool _loading = false;
  String? _error;
  
  List<Vehicle> get vehicles => _vehicles;
  bool get loading => _loading;
  String? get error => _error;
  
  Future<void> fetchVehicles() async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await VehicleService().getVehicles();
      _vehicles = response;
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Other methods...
}
```

### API Services

Services handle API communication with the backend:

```dart
class VehicleService {
  final String baseUrl = 'https://api.ecar.tn/api/v1';
  
  Future<List<Vehicle>> getVehicles() async {
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/vehicles'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Vehicle.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load vehicles');
    }
  }
  
  // Other API methods...
}
```

### Models

Data models represent the application's domain objects:

```dart
class Vehicle {
  final int id;
  final int customerId;
  final String brand;
  final String model;
  final int year;
  final String licensePlate;
  final String vin;
  int currentMileage;
  final double averageDailyUsage;
  final DateTime nextServiceDueDate;
  final int daysUntilNextService;
  
  Vehicle({
    required this.id,
    required this.customerId,
    required this.brand,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.vin,
    required this.currentMileage,
    required this.averageDailyUsage,
    required this.nextServiceDueDate,
    required this.daysUntilNextService,
  });
  
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      customerId: json['customer_id'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      licensePlate: json['license_plate'],
      vin: json['vin'],
      currentMileage: json['current_mileage'],
      averageDailyUsage: json['average_daily_usage'],
      nextServiceDueDate: DateTime.parse(json['next_service_due_date']),
      daysUntilNextService: json['days_until_next_service'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'brand': brand,
      'model': model,
      'year': year,
      'license_plate': licensePlate,
      'vin': vin,
      'current_mileage': currentMileage,
      'average_daily_usage': averageDailyUsage,
      'next_service_due_date': nextServiceDueDate.toIso8601String(),
      'days_until_next_service': daysUntilNextService,
    };
  }
}
```

## UI Components

### Screen Structure

Each screen follows a similar structure:

```dart
class VehicleListScreen extends StatefulWidget {
  @override
  _VehicleListScreenState createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<VehicleProvider>(context, listen: false).fetchVehicles()
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Vehicles')),
      body: Consumer<VehicleProvider>(
        builder: (context, provider, child) {
          if (provider.loading) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }
          
          if (provider.vehicles.isEmpty) {
            return Center(child: Text('No vehicles found'));
          }
          
          return ListView.builder(
            itemCount: provider.vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = provider.vehicles[index];
              return VehicleCard(vehicle: vehicle);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add vehicle screen
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
```

### Custom Widgets

Common widgets are extracted for reuse:

```dart
class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  
  const VehicleCard({required this.vehicle});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(Icons.directions_car),
        title: Text('${vehicle.brand} ${vehicle.model}'),
        subtitle: Text('License: ${vehicle.licensePlate}'),
        trailing: Text('${vehicle.year}'),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => VehicleDetailScreen(vehicleId: vehicle.id),
            ),
          );
        },
      ),
    );
  }
}
```

## Authentication Flow

1. The app starts with a splash screen that checks for existing authentication tokens
2. If a valid token exists, the user is redirected to the home screen
3. If no token exists or the token is expired, the user is shown the login screen
4. After successful login, the token is stored securely using `flutter_secure_storage`

## Navigation

The app uses a bottom navigation bar for main sections:

```dart
BottomNavigationBar(
  currentIndex: _selectedIndex,
  onTap: (index) {
    setState(() {
      _selectedIndex = index;
    });
  },
  items: [
    BottomNavigationBarItem(
      icon: Icon(Icons.directions_car),
      label: 'Vehicles',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.build),
      label: 'Repairs',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.receipt),
      label: 'Invoices',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ),
  ],
)
```

## Internationalization

The app supports both English and Arabic languages using the `flutter_localizations` package:

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
  locale: _locale, // Current locale
  // ...
)
```

Strings are defined in JSON files:

```
assets/
└── i18n/
    ├── en.json
    └── ar.json
```

## Testing

### Unit Tests

Unit tests are located in the `test/` directory and focus on testing individual components:

```dart
void main() {
  group('Vehicle Model Tests', () {
    test('should create Vehicle from JSON', () {
      final json = {
        'id': 1,
        'customer_id': 1,
        'brand': 'BMW',
        'model': '3 Series',
        'year': 2020,
        'license_plate': '123 TUN 4567',
        'vin': 'WBA8E9C5XKB301928',
        'current_mileage': 25000,
        'average_daily_usage': 42.5,
        'next_service_due_date': '2025-06-15',
        'days_until_next_service': 45,
      };
      
      final vehicle = Vehicle.fromJson(json);
      
      expect(vehicle.id, 1);
      expect(vehicle.brand, 'BMW');
      expect(vehicle.model, '3 Series');
      expect(vehicle.year, 2020);
      expect(vehicle.licensePlate, '123 TUN 4567');
    });
  });
}
```

### Widget Tests

Widget tests verify UI components:

```dart
void main() {
  testWidgets('VehicleCard displays vehicle information correctly', (WidgetTester tester) async {
    final vehicle = Vehicle(
      id: 1,
      customerId: 1,
      brand: 'BMW',
      model: '3 Series',
      year: 2020,
      licensePlate: '123 TUN 4567',
      vin: 'WBA8E9C5XKB301928',
      currentMileage: 25000,
      averageDailyUsage: 42.5,
      nextServiceDueDate: DateTime.parse('2025-06-15'),
      daysUntilNextService: 45,
    );
    
    await tester.pumpWidget(
      MaterialApp(
        home: VehicleCard(vehicle: vehicle),
      ),
    );
    
    expect(find.text('BMW 3 Series'), findsOneWidget);
    expect(find.text('License: 123 TUN 4567'), findsOneWidget);
    expect(find.text('2020'), findsOneWidget);
  });
}
```

## Building and Deployment

### Android

```bash
flutter build apk --release
```

The APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`

### iOS

```bash
flutter build ios --release
```

For iOS, you'll need to use Xcode to create and publish the IPA file.

## Troubleshooting

Common issues and their solutions:

1. **Authentication fails**: Check that the API base URL is correct and that you're sending the token in the correct format
2. **API requests time out**: Ensure the device has internet connectivity and the backend server is running
3. **Error loading data**: Check the error messages in the console and verify API response formats match the model classes
4. **UI displays incorrectly**: Test on different device sizes to ensure responsive design works properly 