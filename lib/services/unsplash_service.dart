import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/photo.dart';
import 'dart:developer' as dev;

class UnsplashService {
  static const String _baseUrl = AppConfig.unsplashApiUrl;
  
  final http.Client _client;

  UnsplashService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Photo>> getPhotos({int page = 1, int perPage = 10}) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/photos?page=$page&per_page=$perPage'),
        headers: {
          'Authorization': 'Client-ID ${AppConfig.unsplashAccessKey}',
          'Accept-Version': 'v1',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // print the response body as string
        // dev.log('Response body: ${response.body}');

        return data.map((json) => Photo.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load photos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load photos: $e');
    }
  }

  void dispose() {
    _client.close();
  }
} 