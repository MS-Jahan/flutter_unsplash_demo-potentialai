import 'package:http/http.dart' as http;

class UnsplashService {
  static const String _baseUrl = 'https://api.unsplash.com';
  // TODO: Add your Unsplash API access key
  static const String _accessKey = '';

  Future<List<dynamic>> getPhotos({int page = 1, int perPage = 30}) async {
    // TODO: Implement photo fetching
    return [];
  }
} 