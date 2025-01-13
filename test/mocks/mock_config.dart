import 'package:flutter_unsplash_demo/config/app_config.dart';

class MockAppConfig extends AppConfig {
  static const testAccessKey = 'test_access_key_12345';
  
  static void setupTest() {
    AppConfig.overrideValues(
      unsplashAccessKey: testAccessKey,
    );
  }
} 