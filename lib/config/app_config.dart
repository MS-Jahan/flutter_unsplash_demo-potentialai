import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String unsplashApiUrl = 'https://api.unsplash.com';
  
  // Get access key from .env file
  static String get unsplashAccessKey => 
      dotenv.env['UNSPLASH_ACCESS_KEY'] ?? 
      const String.fromEnvironment(
        'UNSPLASH_ACCESS_KEY',
        defaultValue: '',
      );

  // Validate configuration
  static bool validateConfig() {
    if (unsplashAccessKey.isEmpty) {
      throw AssertionError(
        'Unsplash Access Key not found. Please set UNSPLASH_ACCESS_KEY in .env file or provide it via --dart-define',
      );
    }
    return true;
  }
} 