import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../services/cache_service.dart';
import '../theme/theme_provider.dart';
import '../config/app_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _accessKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAccessKey();
  }

  Future<void> _loadAccessKey() async {
    final prefs = await SharedPreferences.getInstance();
    final accessKey = prefs.getString('unsplashAccessKey');
    if (accessKey != null) {
      _accessKeyController.text = accessKey;
      AppConfig.overrideValues(unsplashAccessKey: accessKey);
    }
  }

  @override
  void dispose() {
    _accessKeyController.dispose();
    super.dispose();
  }

  void _clearCache(BuildContext context) async {
    await CacheService.clearCache();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache cleared successfully')),
    );
  }

  Future<void> _saveAccessKey() async {
    final newAccessKey = _accessKeyController.text.trim();

    if (newAccessKey.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('unsplashAccessKey');
      AppConfig.overrideValues(unsplashAccessKey: null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Using default Unsplash access key')),
      );
      return;
    }

    final isValid = await _checkAccessKey(newAccessKey);

    if (isValid) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('unsplashAccessKey', newAccessKey);
      AppConfig.overrideValues(unsplashAccessKey: newAccessKey);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Access key saved successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Unsplash access key')),
      );
    }
  }

  Future<bool> _checkAccessKey(String accessKey) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.unsplashApiUrl}/photos?page=1&per_page=1'),
        headers: {
          'Authorization': 'Client-ID $accessKey',
          'Accept-Version': 'v1',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Clear Cache'),
            trailing: ElevatedButton(
              onPressed: () => _clearCache(context),
              child: const Text('Clear'),
            ),
          ),
          ListTile(
            title: const Text('Theme'),
            subtitle: const Text('Select your preferred theme'),
            trailing: DropdownButton<ThemeMode>(
              value: themeProvider.themeMode,
              onChanged: (ThemeMode? newThemeMode) {
                if (newThemeMode != null) {
                  themeProvider.toggleTheme(newThemeMode);
                }
              },
              items: ThemeMode.values.map((ThemeMode themeMode) {
                return DropdownMenuItem<ThemeMode>(
                  value: themeMode,
                  child: Text(themeMode.toString().split('.').last),
                );
              }).toList(),
            ),
          ),
          ListTile(
            title: const Text('Unsplash Access Key'),
            subtitle: TextField(
              controller: _accessKeyController,
              decoration: const InputDecoration(
                hintText: 'Enter your Unsplash access key',

              ),
              obscureText: true,
            ),
            trailing: ElevatedButton(
              onPressed: _saveAccessKey,
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
