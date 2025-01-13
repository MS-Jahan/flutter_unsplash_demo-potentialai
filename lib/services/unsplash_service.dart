import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/photo.dart';
import 'cache_service.dart';
// import 'dart:developer' as dev;

typedef PhotoUpdateCallback = void Function(List<Photo> photos);

class UnsplashService {
  static const String _baseUrl = AppConfig.unsplashApiUrl;
  final http.Client _client;
  PhotoUpdateCallback? onPhotosUpdated;

  UnsplashService({http.Client? client}) : _client = client ?? http.Client();

  Future<bool> _hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<List<Photo>> getPhotos({int page = 1, int perPage = 10}) async {
    final hasInternet = await _hasInternetConnection();
    final cachedPhotos = await CacheService.getCachedPhotos();

    if (page <= 2) {
      if (hasInternet) {
        // If we have cached data, return it immediately and refresh in background
        if (cachedPhotos != null) {
          _refreshFirstPageInBackground(perPage);
          return cachedPhotos;
        }
        // If no cache, fetch directly
        return _fetchPhotos(page: page, perPage: perPage);
      } else {
        // No internet, return cache or throw
        if (cachedPhotos != null) {
          return cachedPhotos;
        }
        throw Exception('No internet connection and no cached data available');
      }
    } else {
      // For subsequent pages, we need internet
      if (!hasInternet) {
        throw Exception('No internet connection available for loading more photos');
      }
      return _fetchPhotos(page: page, perPage: perPage);
    }
  }

  Future<List<Photo>> _fetchPhotos({required int page, required int perPage}) async {
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
        final photos = data.map((json) => Photo.fromJson(json)).toList();
        
        // Cache only the first 2 pages
        if (page <= 2) {
          await CacheService.cachePhotos(photos);
        }

        return photos;
      } else {
        throw Exception('Failed to load photos: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to load photos: $e');
      throw Exception('Failed to load photos: $e');
    }
  }

  Future<List<Photo>> searchPhotos(String query, {int page = 1, int perPage = 40}) async {
    try {
      final url = '$_baseUrl/search/photos?query=$query&page=$page&per_page=$perPage';
      // dev.log('Search URL: $url');
      final response = await _client.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Client-ID ${AppConfig.unsplashAccessKey}',
          'Accept-Version': 'v1',
        },
      );

      if (response.statusCode == 200) {
        // dev.log('Search response: ${response.body}');
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        return results.map((json) => Photo.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search photos: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to search photos: $e');
      throw Exception('Failed to search photos: $e');
    }
  }

  Future<void> _refreshFirstPageInBackground(int perPage) async {
    try {
      final freshPhotos = await _fetchPhotos(page: 1, perPage: perPage);
      onPhotosUpdated?.call(freshPhotos);
    } catch (e) {
      // Silently fail as we still have cached data to show
      print('Background refresh failed: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    final context = _getContext();
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  BuildContext? _getContext() {
    // Implement a way to get the current BuildContext
    // This could be done by passing the context from the UI layer
    return null;
  }

  void dispose() {
    _client.close();
  }
}