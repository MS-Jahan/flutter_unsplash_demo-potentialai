import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

class GalleryService {
  static Dio? _dio;

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

  /// Downloads an image to a temporary file
  static Future<(bool, String)> downloadImage(String imageUrl, String tempPath) async {
    try {
      await dio.download(imageUrl, tempPath);
      return (true, 'Image downloaded successfully');
    } on DioException catch (e) {
      return (false, 'Failed to download image: ${e.message}');
    } catch (e) {
      return (false, 'Error downloading image: $e');
    }
  }

  static Future<(bool, String)> saveImage(String imageUrl, String filename) async {
    try {
      if (!await requestPermissions()) {
        return (false, 'Permission denied to save photos');
      }

      // Get temporary file path
      final tempPath = await getTemporaryFilePath(filename);

      // Download image
      final (success, message) = await downloadImage(imageUrl, tempPath);
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