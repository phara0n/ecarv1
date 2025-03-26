import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storage = const FlutterSecureStorage();
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'TND';
  String _selectedDateFormat = 'DD/MM/YYYY';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load settings from secure storage
    final notifications = await _storage.read(key: 'notifications_enabled');
    final darkMode = await _storage.read(key: 'dark_mode_enabled');
    final language = await _storage.read(key: 'selected_language');
    final currency = await _storage.read(key: 'selected_currency');
    final dateFormat = await _storage.read(key: 'date_format');

    setState(() {
      _notificationsEnabled = notifications == 'true';
      _darkModeEnabled = darkMode == 'true';
      _selectedLanguage = language ?? 'English';
      _selectedCurrency = currency ?? 'TND';
      _selectedDateFormat = dateFormat ?? 'DD/MM/YYYY';
    });
  }

  Future<void> _saveSettings() async {
    // Save settings to secure storage
    await _storage.write(key: 'notifications_enabled', value: _notificationsEnabled.toString());
    await _storage.write(key: 'dark_mode_enabled', value: _darkModeEnabled.toString());
    await _storage.write(key: 'selected_language', value: _selectedLanguage);
    await _storage.write(key: 'selected_currency', value: _selectedCurrency);
    await _storage.write(key: 'date_format', value: _selectedDateFormat);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Notifications Section
          Card(
            child: ListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Receive notifications about repairs and updates'),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Dark Mode Section
          Card(
            child: ListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Enable dark theme for the application'),
              trailing: Switch(
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() {
                    _darkModeEnabled = value;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Language Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Language',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedLanguage,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'English', child: Text('English')),
                      DropdownMenuItem(value: 'French', child: Text('French')),
                      DropdownMenuItem(value: 'Arabic', child: Text('Arabic')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedLanguage = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Currency Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Currency',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCurrency,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'TND', child: Text('TND (Tunisian Dinar)')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR (Euro)')),
                      DropdownMenuItem(value: 'USD', child: Text('USD (US Dollar)')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCurrency = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Date Format Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Date Format',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedDateFormat,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'DD/MM/YYYY', child: Text('DD/MM/YYYY')),
                      DropdownMenuItem(value: 'MM/DD/YYYY', child: Text('MM/DD/YYYY')),
                      DropdownMenuItem(value: 'YYYY-MM-DD', child: Text('YYYY-MM-DD')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedDateFormat = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Backup Section
          Card(
            child: ListTile(
              title: const Text('Backup Data'),
              subtitle: const Text('Create a backup of all data'),
              trailing: IconButton(
                icon: const Icon(Icons.backup),
                onPressed: () {
                  // Implement backup functionality
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // About Section
          Card(
            child: ListTile(
              title: const Text('About'),
              subtitle: const Text('Version 1.0.0'),
              trailing: IconButton(
                icon: const Icon(Icons.info),
                onPressed: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'eCar Garage Admin',
                    applicationVersion: '1.0.0',
                    applicationIcon: const FlutterLogo(size: 50),
                    children: const [
                      Text('eCar Garage Management System'),
                      SizedBox(height: 8),
                      Text('© 2024 eCar. All rights reserved.'),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
} 