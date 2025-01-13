import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cache_service.dart';
import '../theme/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _clearCache(BuildContext context) async {
    await CacheService.clearCache();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache cleared successfully')),
    );
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
        ],
      ),
    );
  }
}
