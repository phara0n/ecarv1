import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';
import 'vehicle_detail_screen.dart';

class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  final VehicleService _vehicleService = VehicleService();
  List<Vehicle>? _vehicles;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    try {
      final vehicles = await _vehicleService.getVehicles();
      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error', style: TextStyle(color: Colors.red[700])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadVehicles,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (_vehicles?.isEmpty ?? true) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No vehicles found', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadVehicles,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadVehicles,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _vehicles!.length,
        itemBuilder: (context, index) {
          final vehicle = _vehicles![index];
          return _buildVehicleCard(vehicle);
        },
      ),
    );
  }
  
  Widget _buildVehicleCard(Vehicle vehicle) {
    // Define brand-specific color
    Color brandColor = Theme.of(context).colorScheme.primary;
    
    // Set brand-specific color
    if (vehicle.brand.toLowerCase().contains('bmw')) {
      brandColor = Theme.of(context).colorScheme.tertiary; // BMW Blue
    } else if (vehicle.brand.toLowerCase().contains('mercedes')) {
      brandColor = Theme.of(context).colorScheme.tertiaryContainer; // Mercedes Silver
    } else if (vehicle.brand.toLowerCase().contains('volkswagen') || 
               vehicle.brand.toLowerCase().contains('audi') ||
               vehicle.brand.toLowerCase().contains('seat')) {
      brandColor = Theme.of(context).colorScheme.onTertiaryContainer; // VW Blue
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VehicleDetailScreen(vehicleId: vehicle.id),
            ),
          ).then((_) => _loadVehicles()); // Refresh data when returning
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle header with brand color
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: brandColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.directions_car, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    '${vehicle.brand} ${vehicle.model}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            
            // Vehicle details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // License plate
                  Row(
                    children: [
                      const Icon(Icons.pin, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        vehicle.licensePlate,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Year
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Year: ${vehicle.year}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Mileage
                  if (vehicle.currentMileage != null)
                    Row(
                      children: [
                        const Icon(Icons.speed, size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Mileage: ${vehicle.currentMileage} km',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Next service due
                  if (vehicle.nextServiceDueDate != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Next service: ${_formatDate(vehicle.nextServiceDueDate!)}',
                        style: TextStyle(
                          color: vehicle.daysUntilNextService != null && vehicle.daysUntilNextService! < 30
                              ? Colors.red[700]
                              : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 