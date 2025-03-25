import 'package:flutter/material.dart';
import '../models/repair.dart';
import '../services/repair_service.dart';
import 'package:intl/intl.dart';

class RepairDetailScreen extends StatefulWidget {
  final int repairId;

  const RepairDetailScreen({super.key, required this.repairId});

  @override
  State<RepairDetailScreen> createState() => _RepairDetailScreenState();
}

class _RepairDetailScreenState extends State<RepairDetailScreen> {
  final RepairService _repairService = RepairService();
  Repair? _repair;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRepairData();
  }

  Future<void> _loadRepairData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final repair = await _repairService.getRepair(widget.repairId);
      
      setState(() {
        _repair = repair;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repair Details'),
      ),
      body: _buildBody(),
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
              onPressed: _loadRepairData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (_repair == null) {
      return const Center(child: Text('Repair not found'));
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(_repair!.status),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _repair!.status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Repair info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Repair Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildInfoRow('Description', _repair!.description),
                  _buildInfoRow('Date', DateFormat('dd/MM/yyyy').format(_repair!.date)),
                  _buildInfoRow('Cost', '${_repair!.cost} TND'),
                  if (_repair!.notes != null && _repair!.notes!.isNotEmpty)
                    _buildInfoRow('Notes', _repair!.notes!),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Next service card
          if (_repair!.nextServiceDueDate != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Next Service',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Next Service Due',
                      DateFormat('dd/MM/yyyy').format(_repair!.nextServiceDueDate!),
                    ),
                    if (_repair!.nextServiceDescription != null)
                      _buildInfoRow('Service Type', _repair!.nextServiceDescription!),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 