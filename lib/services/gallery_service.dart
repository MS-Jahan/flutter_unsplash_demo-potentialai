import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

class GalleryService {
  static final _dio = Dio();

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

  static Future<(bool, String)> saveImage(String imageUrl, String filename) async {
    try {
      if (!await requestPermissions()) {
        return (false, 'Permission denied to save photos');
      }

      // Get temporary directory and create file path
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/$filename.jpg';

      // Download image directly to file
      await _dio.download(imageUrl, tempPath);

      // Save to gallery
      await Gal.putImage(tempPath);

      // Clean up temp file
      await File(tempPath).delete();

      return (true, 'Image saved successfully');
    } on DioException catch (e) {
      return (false, 'Failed to download image: ${e.message}');
    } catch (e) {
      if (e.toString().contains('permission')) {
        return (false, 'Permission denied to save photos');
      }
      return (false, 'Error saving image: $e');
    }
  }

  static void dispose() {
    _dio.close();
  }
} 