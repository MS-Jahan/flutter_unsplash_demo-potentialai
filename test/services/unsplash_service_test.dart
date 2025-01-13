import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_unsplash_demo/services/unsplash_service.dart';
import 'package:flutter_unsplash_demo/models/photo.dart';
import 'package:flutter_unsplash_demo/config/app_config.dart';

void main() {
  group('UnsplashService', () {
    late UnsplashService service;

    setUp(() {
      // Setup test configuration
      AppConfig.overrideValuesTest(unsplashAccessKey: 'test_access_key');
      service = UnsplashService();
    });

    tearDown(() {
      service.dispose();
      AppConfig.resetOverrides();
    });

    test('getPhotos returns list of photos on success', () async {
      final mockClient = MockClient((request) async {
        // Verify request headers and URL
        expect(request.headers['Authorization'], contains('test_access_key'));
        expect(request.url.toString(), contains('/photos'));
        expect(request.url.queryParameters['page'], '1');
        expect(request.url.queryParameters['per_page'], '10');

        // Return mock response
        return http.Response(
          json.encode([
            {
              'id': 'test_id',
              'description': 'test description',
              'alt_description': 'alt description',
              'urls': {
                'raw': 'raw_url',
                'full': 'full_url',
                'regular': 'regular_url',
                'small': 'small_url',
                'thumb': 'thumb_url',
              },
              'links': {
                'self': 'self_link',
                'html': 'html_link',
                'download': 'download_link',
              },
              'user': {
                'username': 'test_user',
                'name': 'Test User',
              },
            }
          ]),
          200,
        );
      });

      service = UnsplashService(client: mockClient);
      final photos = await service.getPhotos();

      expect(photos, isA<List<Photo>>());
      expect(photos.length, 1);
      expect(photos.first.id, 'test_id');
      expect(photos.first.description, 'test description');
      expect(photos.first.urls['regular'], 'regular_url');
      expect(photos.first.user.name, 'Test User');
    });

    test('getPhotos throws exception on error response', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Error message', 400);
      });

      service = UnsplashService(client: mockClient);
      expect(
        () => service.getPhotos(),
        throwsA(isA<Exception>()),
      );
    });

    test('getPhotos handles network error', () async {
      final mockClient = MockClient((request) async {
        throw Exception('Network error');
      });

      service = UnsplashService(client: mockClient);
      expect(
        () => service.getPhotos(),
        throwsA(isA<Exception>()),
      );
    });

    test('getPhotos handles pagination parameters', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.queryParameters['page'], '2');
        expect(request.url.queryParameters['per_page'], '20');
        return http.Response('[]', 200);
      });

      service = UnsplashService(client: mockClient);
      await service.getPhotos(page: 2, perPage: 20);
    });
  });
} 