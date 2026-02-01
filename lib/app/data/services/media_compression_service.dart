import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:video_compress/video_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class MediaCompressionService {
  static const int maxImageSizeKB = 500; // 500KB max per image
  static const int maxVideoSizeMB = 1; // 1MB max for video

  /// Compress image to max 500KB using dart image package
  static Future<File?> compressImage(File imageFile) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Get original file size
      final originalSize = await imageFile.length();

      if (kDebugMode) {
        print(
          'Original image size: ${(originalSize / 1024).toStringAsFixed(2)} KB',
        );
      }

      // If already small enough, return original
      if (originalSize <= maxImageSizeKB * 1024) {
        return imageFile;
      }

      // Read image bytes
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Decode image
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        if (kDebugMode) {
          print('Failed to decode image');
        }
        return imageFile;
      }

      // Resize if too large (max width/height 1080)
      if (image.width > 1080 || image.height > 1080) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? 1080 : null,
          height: image.height > image.width ? 1080 : null,
        );
      }

      // Start with quality 85 and decrease if needed
      int quality = 85;
      File? compressedFile;

      while (quality > 10) {
        // Encode to JPEG with current quality
        final List<int> compressed = img.encodeJpg(image, quality: quality);

        final compressedSize = compressed.length;

        if (kDebugMode) {
          print(
            'Compressed size at quality $quality: ${(compressedSize / 1024).toStringAsFixed(2)} KB',
          );
        }

        if (compressedSize <= maxImageSizeKB * 1024) {
          // Save compressed image
          compressedFile = File(targetPath);
          await compressedFile.writeAsBytes(compressed);
          break;
        }

        quality -= 10;
      }

      if (compressedFile != null) {
        final finalSize = await compressedFile.length();
        if (kDebugMode) {
          print(
            'Final compressed image size: ${(finalSize / 1024).toStringAsFixed(2)} KB',
          );
        }
        return compressedFile;
      }

      // If still can't compress enough, save with lowest quality
      final List<int> finalCompressed = img.encodeJpg(image, quality: 10);
      compressedFile = File(targetPath);
      await compressedFile.writeAsBytes(finalCompressed);

      return compressedFile;
    } catch (e) {
      if (kDebugMode) {
        print('Error compressing image: $e');
      }
      return imageFile; // Return original if compression fails
    }
  }

  /// Compress video to max 1MB
  static Future<File?> compressVideo(File videoFile) async {
    try {
      final originalSize = await videoFile.length();

      if (kDebugMode) {
        print(
          'Original video size: ${(originalSize / 1024 / 1024).toStringAsFixed(2)} MB',
        );
      }

      // If already small enough, return original
      if (originalSize <= maxVideoSizeMB * 1024 * 1024) {
        return videoFile;
      }

      // Compress video with lowest quality first
      final MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        videoFile.path,
        quality: VideoQuality.Res640x480Quality,
        deleteOrigin: false,
        includeAudio: true,
      );

      if (mediaInfo != null && mediaInfo.file != null) {
        final compressedSize = await mediaInfo.file!.length();

        if (kDebugMode) {
          print(
            'Compressed video size: ${(compressedSize / 1024 / 1024).toStringAsFixed(2)} MB',
          );
        }

        // If still too large, compress again without audio
        if (compressedSize > maxVideoSizeMB * 1024 * 1024) {
          if (kDebugMode) {
            print('Still too large, compressing again without audio...');
          }

          final MediaInfo? secondCompress = await VideoCompress.compressVideo(
            videoFile.path,
            quality: VideoQuality.LowQuality,
            deleteOrigin: false,
            includeAudio: false,
          );

          if (secondCompress != null && secondCompress.file != null) {
            final finalSize = await secondCompress.file!.length();
            if (kDebugMode) {
              print(
                'Final video size: ${(finalSize / 1024 / 1024).toStringAsFixed(2)} MB',
              );
            }
            return secondCompress.file;
          }
        }

        return mediaInfo.file;
      }

      if (kDebugMode) {
        print('Video compression failed, returning original');
      }
      return videoFile;
    } catch (e) {
      if (kDebugMode) {
        print('Error compressing video: $e');
      }
      return videoFile; // Return original if compression fails
    }
  }

  /// Generate video thumbnail
  static Future<File?> generateVideoThumbnail(File videoFile) async {
    try {
      final thumbnail = await VideoCompress.getFileThumbnail(
        videoFile.path,
        quality: 50,
        position: -1, // Get thumbnail from the middle
      );

      if (kDebugMode && thumbnail != null) {
        final size = await thumbnail.length();
        print('Thumbnail size: ${(size / 1024).toStringAsFixed(2)} KB');
      }

      return thumbnail;
    } catch (e) {
      if (kDebugMode) {
        print('Error generating thumbnail: $e');
      }
      return null;
    }
  }

  /// Clean up temporary files
  static Future<void> cleanupTemporary() async {
    try {
      await VideoCompress.deleteAllCache();

      // Also clean up temporary compressed images
      final dir = await getTemporaryDirectory();
      final files = dir.listSync();

      for (var file in files) {
        if (file is File && file.path.contains('compressed_')) {
          try {
            await file.delete();
          } catch (e) {
            if (kDebugMode) {
              print('Error deleting temp file: $e');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cleaning up: $e');
      }
    }
  }
}
