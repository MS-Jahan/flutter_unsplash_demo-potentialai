import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_unsplash_demo/screens/gallery_screen.dart';
import 'package:flutter_unsplash_demo/services/unsplash_service.dart';
import 'package:flutter_unsplash_demo/models/photo.dart';
import 'package:flutter_unsplash_demo/config/app_config.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([MockSpec<UnsplashService>()])
import 'gallery_screen_test.mocks.dart';

void main() {
  late MockUnsplashService mockUnsplashService;

  setUp(() {
    AppConfig.overrideValuesTest(unsplashAccessKey: 'test_access_key');
    mockUnsplashService = MockUnsplashService();
  });

  tearDown(() {
    AppConfig.resetOverrides();
  });

  testWidgets('GalleryScreen shows loading indicator initially',
      (WidgetTester tester) async {
    // Setup mock to return empty response after a short delay
    when(mockUnsplashService.getPhotos(page: 1, perPage: 20))
        .thenAnswer((_) async => []);

    await tester.pumpWidget(
      MaterialApp(
        home: GalleryScreen(unsplashService: mockUnsplashService),
      ),
    );

    // Verify initial loading state
    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('GalleryScreen shows error on API failure',
      (WidgetTester tester) async {
    const errorMessage = 'API Error';
    when(mockUnsplashService.getPhotos(page: 1, perPage: 20))
        .thenAnswer((_) async => throw Exception(errorMessage));

    await tester.pumpWidget(
      MaterialApp(
        home: GalleryScreen(unsplashService: mockUnsplashService),
      ),
    );

    // Wait for error state
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify error UI components
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('Exception: $errorMessage'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('GalleryScreen shows photos on successful load',
      (WidgetTester tester) async {
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

    await tester.pumpWidget(
      MaterialApp(
        home: GalleryScreen(unsplashService: mockUnsplashService),
      ),
    );

    // Wait for photos to load
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify grid and photo cards
    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(Card), findsAtLeastNWidgets(1));
    expect(find.byType(CachedNetworkImage), findsAtLeastNWidgets(1));
  });

  testWidgets('GalleryScreen loads more photos on scroll',
      (WidgetTester tester) async {
    // Set a fixed size for the test screen
    const screenHeight = 800.0;
    tester.binding.window.physicalSizeTestValue = const Size(400, screenHeight);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    
    final mockPhotos = List.generate(
      20,
      (i) => Photo(
        id: 'test_id_$i',
        description: 'Test photo $i',
        urls: {
          'small': 'thumb_url_$i',
          'regular': 'regular_url_$i',
          'raw': 'raw_url_$i',
        },
        links: {'self': 'self_link'},
        user: PhotoUser(
          id: 'user_$i',
          username: 'test_user',
          name: 'Test User',
        ),
      ),
    );

    // Setup mock responses for initial load and scroll load
    when(mockUnsplashService.getPhotos(page: 1, perPage: 20))
        .thenAnswer((_) async => mockPhotos);
    when(mockUnsplashService.getPhotos(page: 2, perPage: 20))
        .thenAnswer((_) async => mockPhotos);

    await tester.pumpWidget(
      MaterialApp(
        home: GalleryScreen(unsplashService: mockUnsplashService),
      ),
    );

    // Wait for initial load
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify initial load
    verify(mockUnsplashService.getPhotos(page: 1, perPage: 20)).called(1);

    // Scroll to trigger load more
    await tester.drag(find.byType(GridView), const Offset(0, -1000));
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify second page load
    verify(mockUnsplashService.getPhotos(page: 2, perPage: 20)).called(1);
  });

  testWidgets('GalleryScreen refreshes on pull-to-refresh',
      (WidgetTester tester) async {
    // Set a fixed size for the test screen
    const screenHeight = 800.0;
    tester.binding.window.physicalSizeTestValue = const Size(400, screenHeight);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);

    // Set up mock response for first page only
    when(mockUnsplashService.getPhotos(page: 1, perPage: 20))
        .thenAnswer((_) async => []);

    await tester.pumpWidget(
      MaterialApp(
        home: GalleryScreen(unsplashService: mockUnsplashService),
      ),
    );

    // Wait for initial load
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Find the grid view
    final gridView = find.byType(GridView);
    expect(gridView, findsOneWidget);

    // Replace the pull-to-refresh part with:
    await tester.fling(gridView, Offset(0, 300), 1000);
    await tester.pump(); // Start animation
    await tester.pump(Duration(seconds: 1)); // Wait for indicator
    await tester.pumpAndSettle(Duration(seconds: 2)); // Wait for refresh to complete

    // Verify the calls - keep this part the same
    verify(mockUnsplashService.getPhotos(page: 1, perPage: 20)).called(2);
    // calls.called(2);
  });
}