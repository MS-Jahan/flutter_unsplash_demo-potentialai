import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'screens/gallery_screen.dart';
import 'services/cache_service.dart';
import 'theme/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables
  await dotenv.load(fileName: ".env");
  // Validate configuration before running the app
  AppConfig.validateConfig();
  await CacheService.init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const UnsplashGalleryApp(),
    ),
  );
}

class UnsplashGalleryApp extends StatelessWidget {
  const UnsplashGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Unsplash Gallery',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode ?? ThemeMode.system,
      home: const GalleryScreen(),
    );
  }
}
