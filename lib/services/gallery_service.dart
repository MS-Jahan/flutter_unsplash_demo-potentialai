import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

typedef DownloadStatusCallback = void Function(String message);

class GalleryService {
  static Dio? _dio;
  static final _cacheManager = DefaultCacheManager();

  static Dio get dio {
    _dio ??= Dio();
    return _dio!;
  }

  static Future<bool> requestPermissions() async {
    try {
      if (!await Gal.hasAccess()) {
        return await Gal.requestAccess();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Gets the temporary file path for a given filename
  static Future<String> getTemporaryFilePath(String filename) async {
    final tempDir = await getTemporaryDirectory();
    return '${tempDir.path}/$filename.jpg';
  }

  /// Checks if an image is cached and returns its file path
  static Future<String?> getCachedFilePath(String imageUrl) async {
    try {
      final fileInfo = await _cacheManager.getFileFromCache(imageUrl);
      return fileInfo?.file.path;
    } catch (e) {
      return null;
    }
  }

  /// Downloads an image to a temporary file, using cache if available
  static Future<(bool, String)> downloadImage(
    String imageUrl, 
    String tempPath, {
    DownloadStatusCallback? onDownloadStarted,
  }) async {
    try {
      // Check if image is cached
      final cachedPath = await getCachedFilePath(imageUrl);
      if (cachedPath != null) {
        // Copy cached file to temp path
        await File(cachedPath).copy(tempPath);
        return (true, 'Image retrieved from cache');
      }

      // If not cached, notify download start
      onDownloadStarted?.call('Image is being downloaded...');

      // Download and cache
      await dio.download(imageUrl, tempPath);
      
      // Cache the downloaded file
      await _cacheManager.putFile(
        imageUrl,
        await File(tempPath).readAsBytes(),
        fileExtension: 'jpg',
      );

      return (true, 'Image downloaded and cached successfully');
    } on DioException catch (e) {
      return (false, 'Failed to download image: ${e.message}');
    } catch (e) {
      return (false, 'Error downloading image: $e');
    }
  }

  static Future<(bool, String)> saveImage(
    String imageUrl, 
    String filename, {
    DownloadStatusCallback? onDownloadStarted,
  }) async {
    try {
      if (!await requestPermissions()) {
        return (false, 'Permission denied to save photos');
      }

      // Get temporary file path
      final tempPath = await getTemporaryFilePath(filename);

      // Download image or get from cache
      final (success, message) = await downloadImage(
        imageUrl, 
        tempPath,
        onDownloadStarted: onDownloadStarted,
      );
      if (!success) {
        return (false, message);
      }

      // Save to gallery
      await Gal.putImage(tempPath);

      // Clean up temp file
      await File(tempPath).delete();

      return (true, 'Image saved successfully');
    } catch (e) {
      if (e.toString().contains('permission')) {
        return (false, 'Permission denied to save photos');
      }
      return (false, 'Error saving image: $e');
    }
  }

  static void dispose() {
    _dio?.close();
    _dio = null;
  }
} 