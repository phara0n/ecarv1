import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../models/repair.dart';
import '../services/vehicle_service.dart';
import '../services/repair_service.dart';
import 'update_mileage_screen.dart';
import 'repair_detail_screen.dart';

class VehicleDetailScreen extends StatefulWidget {
  final int vehicleId;

  const VehicleDetailScreen({super.key, required this.vehicleId});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  final VehicleService _vehicleService = VehicleService();
  final RepairService _repairService = RepairService();
  Vehicle? _vehicle;
  List<Repair>? _repairs;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVehicleData();
  }

  Future<void> _loadVehicleData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final vehicle = await _vehicleService.getVehicle(widget.vehicleId);
      
      // Fetch repairs for this vehicle
      List<Repair> repairs = [];
      try {
        repairs = await _repairService.getRepairsForVehicle(widget.vehicleId);
      } catch (e) {
        // If we can't load repairs, we'll just show an empty list
        // but we don't want to fail the whole screen
        print('Failed to load repairs: $e');
      }
      
      setState(() {
        _vehicle = vehicle;
        _repairs = repairs;
        _isLoading = false;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_vehicle != null ? '${_vehicle!.brand} ${_vehicle!.model}' : 'Vehicle Details'),
      ),
      body: _buildBody(),
      floatingActionButton: _vehicle != null
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateMileageScreen(vehicle: _vehicle!),
                  ),
                ).then((_) => _loadVehicleData());
              },
              icon: const Icon(Icons.speed),
              label: const Text('Update Mileage'),
            )
          : null,
    );
  }

  Widget _buildBody() {
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
              onPressed: _loadVehicleData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (_vehicle == null) {
      return const Center(child: Text('Vehicle not found'));
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVehicleInfoCard(),
          const SizedBox(height: 24),
          _buildServiceInfoCard(),
          const SizedBox(height: 24),
          _buildRepairsSection(),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vehicle Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow('Brand', _vehicle!.brand),
            _buildInfoRow('Model', _vehicle!.model),
            _buildInfoRow('Year', _vehicle!.year.toString()),
            _buildInfoRow('License Plate', _vehicle!.licensePlate),
            if (_vehicle!.vin != null) _buildInfoRow('VIN', _vehicle!.vin!),
            if (_vehicle!.currentMileage != null) 
              _buildInfoRow('Current Mileage', '${_vehicle!.currentMileage} km'),
            if (_vehicle!.averageDailyUsage != null) 
              _buildInfoRow('Average Daily Usage', '${_vehicle!.averageDailyUsage} km/day'),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Service Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            if (_vehicle!.nextServiceDueDate != null) ...[
              _buildInfoRow('Next Service Due', _formatDate(_vehicle!.nextServiceDueDate!)),
              if (_vehicle!.daysUntilNextService != null)
                _buildInfoRow(
                  'Days Until Service', 
                  _vehicle!.daysUntilNextService.toString(),
                  valueColor: _vehicle!.daysUntilNextService! < 30 ? Colors.red[700] : null,
                ),
            ] else
              const Text('No scheduled service information available'),
          ],
        ),
      ),
    );
  }

  Widget _buildRepairsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Repair History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_repairs == null || _repairs!.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('No repair history available'),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _repairs!.length,
            itemBuilder: (context, index) {
              final repair = _repairs![index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(repair.description),
                  subtitle: Text('${_formatDate(repair.date)} - ${repair.status}'),
                  trailing: Text('${repair.cost} TND'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RepairDetailScreen(repairId: repair.id),
                      ),
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 