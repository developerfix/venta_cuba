import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ImageUploadHelper {
  static const int MAX_IMAGE_SIZE = 2 * 1024 * 1024; // 2MB max size
  static const int IMAGE_QUALITY = 70; // 70% quality for compression
  
  /// Compress image file to reduce size before upload
  static Future<File?> compressImage(File imageFile) async {
    try {
      print('🖼️ Original image size: ${await imageFile.length()} bytes');
      
      // Check if compression is needed
      final fileSize = await imageFile.length();
      if (fileSize <= MAX_IMAGE_SIZE) {
        print('✅ Image size is acceptable, no compression needed');
        return imageFile;
      }
      
      // Get temporary directory for compressed image
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      
      // Compress the image
      XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: IMAGE_QUALITY,
        minWidth: 1024,
        minHeight: 1024,
        format: CompressFormat.jpeg,
      );
      
      if (compressedFile != null) {
        File compressed = File(compressedFile.path);
        print('✅ Compressed image size: ${await compressed.length()} bytes');
        return compressed;
      }
      
      return imageFile;
    } catch (e) {
      print('❌ Error compressing image: $e');
      return imageFile; // Return original if compression fails
    }
  }
  
  /// Validate image file before upload
  static Future<bool> validateImage(File imageFile) async {
    try {
      // Check if file exists
      if (!await imageFile.exists()) {
        print('❌ Image file does not exist');
        return false;
      }
      
      // Check file extension
      String extension = path.extension(imageFile.path).toLowerCase();
      List<String> allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
      
      if (!allowedExtensions.contains(extension)) {
        print('❌ Invalid image format: $extension');
        return false;
      }
      
      // Check file size
      final fileSize = await imageFile.length();
      const maxSize = 10 * 1024 * 1024; // 10MB absolute max
      
      if (fileSize > maxSize) {
        print('❌ Image too large: ${fileSize / (1024 * 1024)} MB');
        return false;
      }
      
      print('✅ Image validation passed');
      return true;
    } catch (e) {
      print('❌ Error validating image: $e');
      return false;
    }
  }
  
  /// Process multiple images for upload
  static Future<List<String>> processImagesForUpload(List<String> imagePaths) async {
    List<String> processedPaths = [];
    
    for (String imagePath in imagePaths) {
      try {
        File imageFile = File(imagePath);
        
        // Validate image
        bool isValid = await validateImage(imageFile);
        if (!isValid) {
          print('⚠️ Skipping invalid image: $imagePath');
          continue;
        }
        
        // Compress image if needed
        File? compressed = await compressImage(imageFile);
        if (compressed != null) {
          processedPaths.add(compressed.path);
        }
      } catch (e) {
        print('❌ Error processing image $imagePath: $e');
      }
    }
    
    return processedPaths;
  }
  
  /// Get file size in human readable format
  static String getFileSizeString(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    var i = 0;
    double size = bytes.toDouble();
    
    while (size > 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    
    return "${size.toStringAsFixed(2)} ${suffixes[i]}";
  }
  
  /// Check server upload limits (for debugging)
  static Map<String, dynamic> getUploadDebugInfo() {
    return {
      'max_image_size': '${MAX_IMAGE_SIZE / (1024 * 1024)} MB',
      'compression_quality': '$IMAGE_QUALITY%',
      'allowed_formats': 'jpg, jpeg, png, gif, webp',
      'recommendation': 'Images will be automatically compressed if larger than 2MB',
    };
  }
}
