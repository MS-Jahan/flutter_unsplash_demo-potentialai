import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/app_config.dart';
import 'screens/gallery_screen.dart';

Future<void> main() async {
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Validate configuration before running the app
  AppConfig.validateConfig();
  runApp(const UnsplashGalleryApp());
}

class UnsplashGalleryApp extends StatelessWidget {
  const UnsplashGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unsplash Gallery',
      // debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const GalleryScreen(),
    );
  }
}
