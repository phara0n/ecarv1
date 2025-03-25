import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> {
  late SharedPreferences _prefs;
  bool _isLoading = true;
  bool _repairUpdates = true;
  bool _invoiceNotifications = true;
  bool _promotions = false;
  bool _serviceReminders = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _repairUpdates = _prefs.getBool('notifications_repair_updates') ?? true;
      _invoiceNotifications = _prefs.getBool('notifications_invoices') ?? true;
      _promotions = _prefs.getBool('notifications_promotions') ?? false;
      _serviceReminders = _prefs.getBool('notifications_service_reminders') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _savePreferences() async {
    await _prefs.setBool('notifications_repair_updates', _repairUpdates);
    await _prefs.setBool('notifications_invoices', _invoiceNotifications);
    await _prefs.setBool('notifications_promotions', _promotions);
    await _prefs.setBool('notifications_service_reminders', _serviceReminders);
    
    // Update FCM topic subscriptions
    final NotificationService notificationService = NotificationService();
    
    // Handle repair updates topic
    if (_repairUpdates) {
      await notificationService.subscribeToTopic('repair_updates');
    } else {
      await notificationService.unsubscribeFromTopic('repair_updates');
    }
    
    // Handle invoice notifications topic
    if (_invoiceNotifications) {
      await notificationService.subscribeToTopic('invoices');
    } else {
      await notificationService.unsubscribeFromTopic('invoices');
    }
    
    // Handle promotions topic
    if (_promotions) {
      await notificationService.subscribeToTopic('promotions');
    } else {
      await notificationService.unsubscribeFromTopic('promotions');
    }
    
    // Handle service reminders topic
    if (_serviceReminders) {
      await notificationService.subscribeToTopic('service_reminders');
    } else {
      await notificationService.unsubscribeFromTopic('service_reminders');
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification preferences saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Preferences'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildInfoCard(),
                const SizedBox(height: 24),
                _buildNotificationToggle(
                  title: 'Repair Status Updates',
                  subtitle: 'Get notified when your repair status changes',
                  value: _repairUpdates,
                  onChanged: (value) {
                    setState(() {
                      _repairUpdates = value;
                    });
                  },
                  icon: Icons.build,
                ),
                const Divider(),
                _buildNotificationToggle(
                  title: 'Invoice Notifications',
                  subtitle: 'Get notified when a new invoice is available',
                  value: _invoiceNotifications,
                  onChanged: (value) {
                    setState(() {
                      _invoiceNotifications = value;
                    });
                  },
                  icon: Icons.receipt,
                ),
                const Divider(),
                _buildNotificationToggle(
                  title: 'Promotions & Offers',
                  subtitle: 'Receive notifications about special offers and promotions',
                  value: _promotions,
                  onChanged: (value) {
                    setState(() {
                      _promotions = value;
                    });
                  },
                  icon: Icons.local_offer,
                ),
                const Divider(),
                _buildNotificationToggle(
                  title: 'Service Reminders',
                  subtitle: 'Get reminders about upcoming service needs',
                  value: _serviceReminders,
                  onChanged: (value) {
                    setState(() {
                      _serviceReminders = value;
                    });
                  },
                  icon: Icons.calendar_today,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _savePreferences,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Save Preferences'),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications_active, 
                     color: Theme.of(context).colorScheme.tertiary),
                const SizedBox(width: 8),
                Text(
                  'Notification Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Control which notifications you receive from eCar Garage. '
              'We recommend keeping service updates and reminders enabled '
              'to stay informed about your vehicle maintenance.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
      ),
    );
  }
} 