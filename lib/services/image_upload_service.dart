import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart';

class ImageUploadService {
  // For demo purposes, we'll use ImgBB as a free image hosting service
  // In production, you might want to use a more robust solution like AWS S3, Cloudinary, etc.
  static const String apiKey = '3d5860aa87a1edb40dead8debc3c983e'; // Get a free key from imgbb.com
  static const String uploadUrl = 'https://api.imgbb.com/1/upload';

  // Upload a single image
  static Future<String?> uploadImage(File imageFile) async {
    try {
      final uri = Uri.parse('$uploadUrl?key=$apiKey');
      final request = http.MultipartRequest('POST', uri);
      
      final fileStream = http.ByteStream(imageFile.openRead());
      final fileLength = await imageFile.length();
      
      final multipartFile = http.MultipartFile(
        'image',
        fileStream,
        fileLength,
        filename: basename(imageFile.path),
      );
      
      request.files.add(multipartFile);
      
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = jsonDecode(responseData);
      
      if (response.statusCode == 200 && jsonData['success'] == true) {
        return jsonData['data']['url'];
      } else {
        print('Image upload failed: ${jsonData['error']['message']}');
        return null;
      }
    } catch (e) {
      print('Exception during image upload: $e');
      return null;
    }
  }

  // Upload multiple images
  static Future<List<String>> uploadImages(List<File> imageFiles) async {
    final List<String> uploadedUrls = [];
    
    for (final imageFile in imageFiles) {
      final url = await uploadImage(imageFile);
      if (url != null) {
        uploadedUrls.add(url);
      }
    }
    
    return uploadedUrls;
  }
  
  // For demo purposes, return placeholder image URLs
  static List<String> getDemoImageUrls(int count) {
    return List.generate(
      count, 
      (index) => 'https://via.placeholder.com/800x600?text=Property+Image+${index + 1}'
    );
  }
}
