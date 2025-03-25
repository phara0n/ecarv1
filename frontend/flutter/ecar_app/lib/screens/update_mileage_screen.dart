import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';

class UpdateMileageScreen extends StatefulWidget {
  final Vehicle vehicle;

  const UpdateMileageScreen({super.key, required this.vehicle});

  @override
  State<UpdateMileageScreen> createState() => _UpdateMileageScreenState();
}

class _UpdateMileageScreenState extends State<UpdateMileageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mileageController = TextEditingController();
  final VehicleService _vehicleService = VehicleService();
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Pre-fill with current mileage if available
    if (widget.vehicle.currentMileage != null) {
      _mileageController.text = widget.vehicle.currentMileage.toString();
    }
  }

  @override
  void dispose() {
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _updateMileage() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final mileage = int.parse(_mileageController.text);
      
      // Validate that new mileage is higher than current mileage
      if (widget.vehicle.currentMileage != null && mileage <= widget.vehicle.currentMileage!) {
        setState(() {
          _isSubmitting = false;
          _error = 'New mileage must be higher than current mileage';
        });
        return;
      }
      
      await _vehicleService.updateMileage(widget.vehicle.id, mileage);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mileage updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Mileage'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle information card
              Card(
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.vehicle.brand} ${widget.vehicle.model}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('License Plate: ${widget.vehicle.licensePlate}'),
                      if (widget.vehicle.currentMileage != null) ...[
                        const SizedBox(height: 8),
                        Text('Current Mileage: ${widget.vehicle.currentMileage} km'),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Mileage input
              const Text(
                'Enter current mileage',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _mileageController,
                decoration: const InputDecoration(
                  hintText: 'Mileage in kilometers',
                  suffixText: 'km',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the current mileage';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: TextStyle(color: Colors.red[700]),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _updateMileage,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Update Mileage'),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Information about mileage updates
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Why update your mileage?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Keeping your mileage up to date helps us provide better service recommendations and remind you about upcoming maintenance needs based on your actual vehicle usage.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 