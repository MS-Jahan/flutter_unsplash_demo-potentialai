import 'package:hive_flutter/hive_flutter.dart';
import '../models/photo.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CacheService {
  static const String _photoBoxName = 'photos';
  static const String _photoListKey = 'photo_list';
  static const Duration _cacheValidity = Duration(hours: 24);
  static final _cacheManager = DefaultCacheManager();

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(PhotoAdapter());
    Hive.registerAdapter(PhotoUserAdapter());
    await Hive.openBox<dynamic>(_photoBoxName);
  }

  static Future<void> cachePhotos(List<Photo> photos) async {
    final box = Hive.box(_photoBoxName);
    final cachedData = box.get(_photoListKey);
    List<Photo> existingPhotos = [];

    if (cachedData != null) {
      existingPhotos = (cachedData['photos'] as List).cast<Photo>();
    }

    // Remove duplicates
    final newPhotos = photos.where((photo) => !existingPhotos.any((existingPhoto) => existingPhoto.id == photo.id)).toList();

    // Append new photos
    existingPhotos.addAll(newPhotos);

    // print length of existingPhotos
    print("existingPhotos length: ${existingPhotos.length}");

    await box.put(_photoListKey, {
      'timestamp': DateTime.now().toIso8601String(),
      'photos': existingPhotos,
    });
  }

  static Future<List<Photo>?> getCachedPhotos() async {
    final box = Hive.box(_photoBoxName);
    final cachedData = box.get(_photoListKey);
    
    if (cachedData == null) return null;

    final timestamp = DateTime.parse(cachedData['timestamp'] as String);
    if (DateTime.now().difference(timestamp) > _cacheValidity) {
      await box.delete(_photoListKey);
      return null;
    }

    return (cachedData['photos'] as List).cast<Photo>();
  }

  static Future<void> clearCache() async {
    try {
      // Clear image cache
      await _cacheManager.emptyCache();

      // Clear Hive cache
      final box = await Hive.openBox(_photoBoxName);
      await box.clear();
      // await box.close();

      final box1 = await Hive.openBox(_photoListKey);
      await box1.clear();
      // await box1.close();
      
      print('Cache cleared successfully');
    } catch (e) {
      print('Error clearing cache: $e');
      // Re-initialize if box is closed
      await init();
    }
  }
}