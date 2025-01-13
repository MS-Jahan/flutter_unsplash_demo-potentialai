import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_unsplash_demo/models/photo.dart';

void main() {
  group('Photo', () {
    test('fromJson creates Photo instance correctly', () {
      final json = {
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
      };

      final photo = Photo.fromJson(json);

      expect(photo.id, 'test_id');
      expect(photo.description, 'test description');
      expect(photo.alt_description, 'alt description');
      expect(photo.urls['raw'], 'raw_url');
      expect(photo.urls['full'], 'full_url');
      expect(photo.urls['regular'], 'regular_url');
      expect(photo.links['self'], 'self_link');
      expect(photo.links['download'], 'download_link');
      expect(photo.user.username, 'test_user');
      expect(photo.user.name, 'Test User');
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': 'test_id',
        'urls': {
          'raw': 'raw_url',
          'full': 'full_url',
          'regular': 'regular_url',
        },
        'links': {
          'self': 'self_link',
        },
        'user': {
          'username': 'test_user',
          'name': 'Test User',
        },
      };

      final photo = Photo.fromJson(json);

      expect(photo.id, 'test_id');
      expect(photo.description, null);
      expect(photo.alt_description, null);
      expect(photo.urls['raw'], 'raw_url');
      expect(photo.user.username, 'test_user');
    });

    test('PhotoUser fromJson creates instance correctly', () {
      final json = {
        'username': 'test_user',
        'name': 'Test User',
      };

      final user = PhotoUser.fromJson(json);

      expect(user.username, 'test_user');
      expect(user.name, 'Test User');
    });
  });
} 