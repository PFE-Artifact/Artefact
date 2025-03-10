import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class ImageUploadService {
  // Default placeholders - these will be replaced with actual values
  String _cloudinaryCloudName = '';
  String _cloudinaryUploadPreset = '';
  String _imgbbApiKey = '';
  bool _keysLoaded = false;

  // Singleton pattern
  static final ImageUploadService _instance = ImageUploadService._internal();

  factory ImageUploadService() {
    return _instance;
  }

  ImageUploadService._internal() {
    _loadApiKeys();
  }

  // Load API keys from SharedPreferences
  Future<void> _loadApiKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cloudinaryCloudName = prefs.getString('dy8lvngsb') ?? '';
      _cloudinaryUploadPreset = prefs.getString('artefact') ?? '';
      _imgbbApiKey = prefs.getString('a53af6f55580a94556f22efc4bfa326c') ?? '';
      _keysLoaded = true;
    } catch (e) {
      print('Error loading API keys: $e');
    }
  }

  // Save API keys to SharedPreferences
  Future<void> saveApiKeys({
    required String cloudinaryCloudName,
    required String cloudinaryUploadPreset,
    required String imgbbApiKey,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cloudinary_cloud_name', cloudinaryCloudName);
      await prefs.setString('cloudinary_upload_preset', cloudinaryUploadPreset);
      await prefs.setString('imgbb_api_key', imgbbApiKey);

      _cloudinaryCloudName = cloudinaryCloudName;
      _cloudinaryUploadPreset = cloudinaryUploadPreset;
      _imgbbApiKey = imgbbApiKey;
      _keysLoaded = true;
    } catch (e) {
      print('Error saving API keys: $e');
    }
  }

  // Check if API keys are configured
  bool get areKeysConfigured {
    return _keysLoaded &&
        _cloudinaryCloudName.isNotEmpty &&
        _cloudinaryUploadPreset.isNotEmpty &&
        _imgbbApiKey.isNotEmpty;
  }

  // Upload image to Cloudinary
  Future<String> uploadToCloudinary(File imageFile) async {
    if (!areKeysConfigured) {
      await _loadApiKeys();
      if (!areKeysConfigured) {
        throw Exception('Cloudinary API keys not configured');
      }
    }

    try {
      final uri = Uri.parse(
          'https://api.cloudinary.com/v1_1/$_cloudinaryCloudName/image/upload'
      );

      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        uri,
        body: {
          'file': 'data:image/jpeg;base64,$base64Image',
          'upload_preset': _cloudinaryUploadPreset,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['secure_url'] ?? '';
      } else {
        print('Cloudinary upload failed: ${response.body}');
        throw Exception('Cloudinary upload failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      throw Exception('Error uploading to Cloudinary: $e');
    }
  }

  // Upload image to ImgBB
  Future<String> uploadToImgBB(File imageFile) async {
    if (!areKeysConfigured) {
      await _loadApiKeys();
      if (_imgbbApiKey.isEmpty) {
        throw Exception('ImgBB API key not configured');
      }
    }

    try {
      final uri = Uri.parse('https://api.imgbb.com/1/upload');

      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        uri,
        body: {
          'key': _imgbbApiKey,
          'image': base64Image,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['data']['url'] ?? '';
      } else {
        print('ImgBB upload failed: ${response.body}');
        throw Exception('ImgBB upload failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading to ImgBB: $e');
      throw Exception('Error uploading to ImgBB: $e');
    }
  }

  // Show dialog to configure API keys
  static Future<void> showConfigDialog(BuildContext context) async {
    final service = ImageUploadService();

    // Controllers for text fields
    final cloudNameController = TextEditingController(text: service._cloudinaryCloudName);
    final uploadPresetController = TextEditingController(text: service._cloudinaryUploadPreset);
    final imgbbKeyController = TextEditingController(text: service._imgbbApiKey);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configure Image Upload'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cloudNameController,
                decoration: const InputDecoration(
                  labelText: 'Cloudinary Cloud Name',
                  hintText: 'Enter your Cloudinary cloud name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: uploadPresetController,
                decoration: const InputDecoration(
                  labelText: 'Cloudinary Upload Preset',
                  hintText: 'Enter your Cloudinary upload preset',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: imgbbKeyController,
                decoration: const InputDecoration(
                  labelText: 'ImgBB API Key',
                  hintText: 'Enter your ImgBB API key',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await service.saveApiKeys(
                cloudinaryCloudName: cloudNameController.text.trim(),
                cloudinaryUploadPreset: uploadPresetController.text.trim(),
                imgbbApiKey: imgbbKeyController.text.trim(),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

