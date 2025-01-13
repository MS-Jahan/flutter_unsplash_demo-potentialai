import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meta/meta.dart';

class AppConfig {
  static const String unsplashApiUrl = 'https://api.unsplash.com';
  
  static String? _testAccessKey;
  static String? _manualAccessKey;
  
  // Get access key from .env file or test override
  static String get unsplashAccessKey => 
      _manualAccessKey ??
      _testAccessKey ??
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

  // For testing purposes only
  @visibleForTesting
  static void overrideValuesTest({String? unsplashAccessKey}) {
    _manualAccessKey = unsplashAccessKey;
    _testAccessKey = unsplashAccessKey;
  }

  static void overrideValues({String? unsplashAccessKey}) {
    _manualAccessKey = unsplashAccessKey;
  }

  // Reset overrides (useful for tearDown in tests)
  @visibleForTesting
  static void resetOverrides() {
    _manualAccessKey = null;
    _testAccessKey = null;
  }
}