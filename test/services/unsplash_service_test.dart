import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_unsplash_demo/services/unsplash_service.dart';
import 'package:flutter_unsplash_demo/models/photo.dart';
import 'package:flutter_unsplash_demo/config/app_config.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'unsplash_service_test.mocks.dart';

@GenerateNiceMocks([MockSpec<UnsplashService>()])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel connectivityChannel = MethodChannel('dev.fluttercommunity.plus/connectivity');

  setUpAll(() {
    connectivityChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'check':
          return 'wifi'; // Return a string for single check
        case 'listen':
          return <String>['wifi']; // Return a list for stream-based calls
        default:
          return null;
      }
    });
  });

  group('UnsplashService', () {
    late UnsplashService service;
    late MockUnsplashService mockUnsplashService;

    setUp(() {
      // Setup test configuration
      AppConfig.overrideValuesTest(unsplashAccessKey: 'test_access_key');
      service = UnsplashService();
      mockUnsplashService = MockUnsplashService();
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

    test('UnsplashService getPhotos returns list of photos on success', () async {
      final mockPhotos = [
        Photo(
          id: '1',
          description: 'Description',
          altDescription: 'Alt description',
          urls: {'small': 'url'},
          links: {'self': 'link'},
          user: PhotoUser(id: '1', username: 'test_user', name: 'Test User'),
        ),
      ];

      when(mockUnsplashService.getPhotos(page: 1, perPage: 20))
          .thenAnswer((_) async => mockPhotos);

      final photos = await mockUnsplashService.getPhotos(page: 1, perPage: 20);

      expect(photos, equals(mockPhotos));
    });
  });
}