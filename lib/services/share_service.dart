import 'dart:io';
import 'package:share_plus/share_plus.dart';
import '../services/gallery_service.dart';

class ShareService {
  static Future<void> shareImage(
    String imageUrl, 
    String title, {
    DownloadStatusCallback? onDownloadStarted,
  }) async {
    try {
      // Get temporary file path
      final filename = 'share_${DateTime.now().millisecondsSinceEpoch}';
      final tempPath = await GalleryService.getTemporaryFilePath(filename);

      // Download the image
      final (success, message) = await GalleryService.downloadImage(
        imageUrl, 
        tempPath,
        onDownloadStarted: onDownloadStarted,
      );
      if (!success) {
        throw Exception(message);
      }

      // Share the image
      await Share.shareXFiles(
        [XFile(tempPath)],
        text: title,
        subject: 'Check out this photo from Unsplash',
      );

      // Clean up temp file
      await File(tempPath).delete();
    } catch (e) {
      throw Exception('Failed to share image: $e');
    }
  }
} 