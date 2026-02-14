import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';
import 'package:path/path.dart' as path;

class MediaCompressionService {
  /// Compress image dengan kualitas baik
  static Future<File?> compressImage(
    File file, {
    int quality = 85,
    int maxWidth = 1920,
    int maxHeight = 1080,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        '${DateTime.now().millisecondsSinceEpoch}_compressed.jpg',
      );

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
        format: CompressFormat.jpeg,
      );

      if (result != null) {
        return File(result.path);
      }

      return null;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }

  /// Compress video dengan target maksimal 5MB
  /// Menggunakan kualitas yang seimbang antara ukuran dan kualitas
  static Future<File?> compressVideo(
    File file, {
    VideoQuality quality = VideoQuality.MediumQuality,
    bool deleteOrigin = false,
    int targetMaxSizeMB = 5,
  }) async {
    try {
      // Dapatkan info video original
      final info = await VideoCompress.getMediaInfo(file.path);

      debugPrint('📹 Original Video Info:');
      debugPrint(
        '   - Size: ${(info.filesize! / 1024 / 1024).toStringAsFixed(2)} MB',
      );
      debugPrint('   - Duration: ${info.duration?.toStringAsFixed(2)}s');
      debugPrint('   - Width: ${info.width}');
      debugPrint('   - Height: ${info.height}');

      final originalSizeMB = info.filesize! / 1024 / 1024;
      final durationInSeconds = info.duration ?? 1;

      // Hitung target bitrate untuk mencapai target size
      // Formula: bitrate (bits/s) = (target_size_MB * 8 * 1024 * 1024) / duration_seconds
      // Dikurangi 20% untuk overhead audio
      final targetBitrate =
          ((targetMaxSizeMB * 8 * 1024 * 1024 * 0.8) / durationInSeconds)
              .toInt();

      debugPrint('🎯 Target Size: $targetMaxSizeMB MB');
      debugPrint(
        '🎯 Calculated Bitrate: ${(targetBitrate / 1000000).toStringAsFixed(2)} Mbps',
      );

      // Tentukan kualitas berdasarkan ukuran original
      VideoQuality selectedQuality;
      if (originalSizeMB > 50) {
        selectedQuality = VideoQuality.LowQuality; // Agresif untuk video besar
      } else if (originalSizeMB > 20) {
        selectedQuality =
            VideoQuality.MediumQuality; // Sedang untuk video medium
      } else {
        selectedQuality =
            VideoQuality.DefaultQuality; // Standar untuk video kecil
      }

      debugPrint('📊 Selected Quality: $selectedQuality');

      // Kompresi dengan kualitas yang dipilih
      final mediaInfo = await VideoCompress.compressVideo(
        file.path,
        quality: selectedQuality,
        deleteOrigin: deleteOrigin,
        includeAudio: true,
        frameRate: 24, // 24fps untuk ukuran lebih kecil tapi masih smooth
      );

      if (mediaInfo != null && mediaInfo.file != null) {
        final compressedSize = await mediaInfo.file!.length();
        final compressedSizeMB = compressedSize / 1024 / 1024;
        final compressionRatio = (compressedSize / info.filesize!) * 100;

        debugPrint('✅ Compressed Video Info:');
        debugPrint('   - Size: ${compressedSizeMB.toStringAsFixed(2)} MB');
        debugPrint('   - Compression: ${compressionRatio.toStringAsFixed(1)}%');
        debugPrint(
          '   - Saved: ${(originalSizeMB - compressedSizeMB).toStringAsFixed(2)} MB',
        );

        // Cek apakah masih terlalu besar
        if (compressedSizeMB > targetMaxSizeMB * 1.2) {
          debugPrint(
            '⚠️  Video masih terlalu besar (${compressedSizeMB.toStringAsFixed(2)} MB), mencoba kompresi lebih agresif...',
          );

          // Kompresi ulang dengan kualitas lebih rendah
          await VideoCompress.deleteAllCache();

          final secondCompression = await VideoCompress.compressVideo(
            file.path,
            quality: VideoQuality.LowQuality,
            deleteOrigin: deleteOrigin,
            includeAudio: true,
            frameRate: 24,
          );

          if (secondCompression != null && secondCompression.file != null) {
            final finalSize = await secondCompression.file!.length();
            final finalSizeMB = finalSize / 1024 / 1024;

            debugPrint('✅ Second Compression:');
            debugPrint('   - Size: ${finalSizeMB.toStringAsFixed(2)} MB');

            return secondCompression.file;
          }
        }

        return mediaInfo.file;
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error compressing video: $e');
      return null;
    }
  }

  /// Generate thumbnail dari video dengan kualitas tinggi
  static Future<File?> generateVideoThumbnail(
    File videoFile, {
    int quality = 90,
  }) async {
    try {
      final thumbnail = await VideoCompress.getFileThumbnail(
        videoFile.path,
        quality: quality,
        position: -1, // Get frame from middle of video
      );

      if (thumbnail != null) {
        debugPrint('✅ Thumbnail generated: ${thumbnail.path}');
        return thumbnail;
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error generating thumbnail: $e');
      return null;
    }
  }

  /// Cleanup temporary files
  static Future<void> cleanupTemporary() async {
    try {
      await VideoCompress.deleteAllCache();
      debugPrint('🧹 Temporary cache cleaned');
    } catch (e) {
      debugPrint('❌ Error cleaning cache: $e');
    }
  }

  /// Cancel ongoing compression
  static void cancelCompression() {
    VideoCompress.cancelCompression();
  }

  /// Get video info without compressing
  static Future<MediaInfo?> getVideoInfo(String path) async {
    try {
      return await VideoCompress.getMediaInfo(path);
    } catch (e) {
      debugPrint('❌ Error getting video info: $e');
      return null;
    }
  }

  /// Compress video dengan opsi advanced
  static Future<File?> compressVideoAdvanced(
    File file, {
    required int targetWidth,
    required int targetHeight,
    required int bitrate,
    int frameRate = 30,
    bool deleteOrigin = false,
  }) async {
    try {
      final mediaInfo = await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: deleteOrigin,
        includeAudio: true,
        frameRate: frameRate,
      );

      return mediaInfo?.file;
    } catch (e) {
      debugPrint('❌ Error in advanced compression: $e');
      return null;
    }
  }
}
