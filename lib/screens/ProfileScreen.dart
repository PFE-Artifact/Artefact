import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:artefacts/providers/theme_provider.dart';
import './services/image_upload_service.dart';
import './widgets/profile_list_item.dart';
import './widgets/settings_switch_item.dart';

// Import LocaleProvider from main.dart
import 'package:artefacts/main.dart' show LocaleProvider;

class ProfileScreen extends StatefulWidget {
  // Accept ThemeProvider as a parameter
  final ThemeProvider? themeProvider;

  const ProfileScreen({Key? key, this.themeProvider}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImageUploadService _imageUploadService = ImageUploadService();

  bool _isLoading = true;
  Map<String, dynamic> _userData = {};
  bool _useFaceId = false;
  bool _showCoins = true;
  bool _incognitoMode = false;
  String? _avatarUrl;
  var _loading = false;
  var _uploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        final docSnapshot = await _firestore.collection('users').doc(userId).get();

        if (docSnapshot.exists) {
          setState(() {
            _userData = docSnapshot.data() ?? {};
            _useFaceId = _userData['useFaceId'] ?? false;
            _showCoins = _userData['showCoins'] ?? true;
            _incognitoMode = _userData['incognitoMode'] ?? false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateUserSetting(String field, dynamic value) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({field: value});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating setting: $e')),
        );
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();

    try {
      // Let user choose between camera and gallery
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Select Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Camera'),
                  ),
                  onTap: () {
                    Navigator.of(context).pop(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Gallery'),
                  ),
                  onTap: () {
                    Navigator.of(context).pop(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        ),
      );

      if (source == null) return;

      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _uploadingImage = true;
      });

      // Try Imgbb as an alternative to Cloudinary
      final imageUrl = await _uploadImageToImgbb(image);

      if (imageUrl != null) {
        setState(() {
          _avatarUrl = imageUrl;
        });

        // Update the avatar URL in Firestore
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'avatarUrl': imageUrl});

          // Reload user data after updating the avatar
          await _loadUserData();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile picture: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _uploadingImage = false;
        });
      }
    }
  }

  Future<String?> _uploadImageToImgbb(XFile imageFile) async {
    // Get ImgBB API key from https://api.imgbb.com/
    const String apiKey = 'a53af6f55580a94556f22efc4bfa326c'; // Replace with your ImgBB API key

    try {
      // Read file as bytes
      final bytes = await imageFile.readAsBytes();

      // Convert to base64
      final base64Image = base64Encode(bytes);

      // Create request
      final uri = Uri.parse('https://api.imgbb.com/1/upload');
      final response = await http.post(
        uri,
        body: {
          'key': apiKey,
          'image': base64Image,
          'name': path.basename(imageFile.path),
        },
      );

      print('ImgBB Response Status: ${response.statusCode}');
      print('ImgBB Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          // Return the direct image URL
          return jsonData['data']['url'];
        } else {
          throw Exception('Failed to upload image: ${jsonData['error']['message']}');
        }
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading to ImgBB: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the ThemeProvider passed as a parameter or try to get it from context
    final themeProvider = widget.themeProvider ??
        (Provider.of<ThemeProvider>(context, listen: false));

    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My account'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.orange,
                      backgroundImage: _userData['avatarUrl'] != null
                          ? NetworkImage(_userData['avatarUrl'])
                          : null,
                      child: _userData['avatarUrl'] == null
                          ? const Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.edit, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Personal Info Section
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Personal info',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    ProfileListItem(
                      icon: Icons.person_outline,
                      title: 'Your name',
                      subtitle: _userData['username']  ?? 'Not set',
                      onTap: () {
                        // Navigate to edit name screen
                      },
                    ),
                    ProfileListItem(
                      icon: Icons.phone_android,
                      title: 'Phone number',
                      subtitle: _userData['phoneNumber'] ??_auth.currentUser?.phoneNumber ?? 'Not set',
                      onTap: () {
                        // Navigate to edit phone screen
                      },
                    ),
                    ProfileListItem(
                      icon: Icons.email_outlined,
                      title: 'Email address',
                      subtitle: _userData['email'] ?? _auth.currentUser?.email ?? 'Not set',
                      onTap: () {
                        // Navigate to edit email screen
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Settings Section
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    SettingsSwitchItem(
                      icon: Icons.face,
                      title: 'Allow Face ID',
                      subtitle: 'Use Face ID to enter into the app',
                      value: _useFaceId,
                      onChanged: (value) {
                        setState(() {
                          _useFaceId = value;
                        });
                        _updateUserSetting('useFaceId', value);
                      },
                    ),
                    SettingsSwitchItem(
                      icon: Icons.attach_money,
                      title: 'Showing Coins',
                      subtitle: 'Amounts in the format 00.00',
                      value: _showCoins,
                      onChanged: (value) {
                        setState(() {
                          _showCoins = value;
                        });
                        _updateUserSetting('showCoins', value);
                      },
                    ),
                    SettingsSwitchItem(
                      icon: Icons.visibility_off,
                      title: 'Incognito mode',
                      subtitle: 'The balance will be hidden',
                      value: _incognitoMode,
                      onChanged: (value) {
                        setState(() {
                          _incognitoMode = value;
                        });
                        _updateUserSetting('incognitoMode', value);
                      },
                    ),
                    ProfileListItem(
                      icon: Icons.lock_outline,
                      title: 'Code to enter into the app',
                      subtitle: 'Change entrance code',
                      onTap: () {
                        // Navigate to change code screen
                      },
                    ),
                    ProfileListItem(
                      icon: Icons.language,
                      title: 'Language',
                      subtitle: 'English',
                      onTap: () {
                        // Show language selection dialog
                        _showLanguageDialog(context);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _auth.signOut();
                    if (mounted) {
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                onTap: () {
                  Provider.of<LocaleProvider>(context, listen: false)
                      .setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Arabic'),
                onTap: () {
                  Provider.of<LocaleProvider>(context, listen: false)
                      .setLocale(const Locale('ar'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
















































/*
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart' as path;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();

  String? _avatarUrl;
  var _loading = false;
  var _uploadingImage = false;

  // Cloudinary configuration - REPLACE THESE VALUES
  final String cloudName = 'dy8lvngsb'; // Replace with your cloud name
  final String uploadPreset = 'artefact'; // Replace with your upload preset

  // For signed uploads (more secure)
  final String apiKey = '321563775929846'; // Replace with your API key
  final String apiSecret = 'lwzORa6hRVgCRAinviUDXhDdyks'; // Replace with your API secret

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _loading = true;
    });

    try {
      // Get the current Firebase user
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // If no user is logged in, redirect to login
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      // Fetch user profile data from Firestore
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userData.exists) {
        // Set the form fields with data from Firestore
        setState(() {
          _usernameController.text = userData.data()?['username'] ?? '';
          _emailController.text = user.email ?? '';
          _bioController.text = userData.data()?['bio'] ?? '';
          _avatarUrl = userData.data()?['avatarUrl'];
        });
      } else {
        // If the user document doesn't exist yet, just use the email
        setState(() {
          _emailController.text = user.email ?? '';
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading profile: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _loading = true;
    });

    final username = _usernameController.text.trim();
    final bio = _bioController.text.trim();

    try {
      // Get the current Firebase user
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('No user is logged in');
      }

      // Update the user profile in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'username': username,
        'bio': bio,
        'email': user.email,
        'updatedAt': FieldValue.serverTimestamp(),
        // Keep the existing avatarUrl if it exists
        if (_avatarUrl != null) 'avatarUrl': _avatarUrl,
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();

    try {
      // Let user choose between camera and gallery
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Select Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Camera'),
                  ),
                  onTap: () {
                    Navigator.of(context).pop(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Gallery'),
                  ),
                  onTap: () {
                    Navigator.of(context).pop(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        ),
      );

      if (source == null) return;

      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _uploadingImage = true;
      });

      // Try Imgbb as an alternative to Cloudinary
      final imageUrl = await _uploadImageToImgbb(image);

      if (imageUrl != null) {
        setState(() {
          _avatarUrl = imageUrl;
        });

        // Update the avatar URL in Firestore
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'avatarUrl': imageUrl});

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile picture: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _uploadingImage = false;
        });
      }
    }
  }

  Future<String?> _uploadImageToImgbb(XFile imageFile) async {
    // Get ImgBB API key from https://api.imgbb.com/
    const String apiKey = 'a53af6f55580a94556f22efc4bfa326c'; // Replace with your ImgBB API key

    try {
      // Read file as bytes
      final bytes = await imageFile.readAsBytes();

      // Convert to base64
      final base64Image = base64Encode(bytes);

      // Create request
      final uri = Uri.parse('https://api.imgbb.com/1/upload');
      final response = await http.post(
        uri,
        body: {
          'key': apiKey,
          'image': base64Image,
          'name': path.basename(imageFile.path),
        },
      );

      print('ImgBB Response Status: ${response.statusCode}');
      print('ImgBB Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          // Return the direct image URL
          return jsonData['data']['url'];
        } else {
          throw Exception('Failed to upload image: ${jsonData['error']['message']}');
        }
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading to ImgBB: $e');
      return null;
    }
  }

  // Alternative method using Cloudinary
  Future<String?> _uploadImageToCloudinary(XFile imageFile) async {
    try {
      // Read file as bytes
      final bytes = await imageFile.readAsBytes();

      // Convert to base64
      final base64Image = base64Encode(bytes);

      // Create request
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      // For debugging - print the URL
      print('Uploading to: $uri');

      final response = await http.post(
        uri,
        body: {
          'file': 'data:image/jpeg;base64,$base64Image',
          'upload_preset': uploadPreset,
        },
      );

      // For debugging - print response
      print('Cloudinary Response Status: ${response.statusCode}');
      print('Cloudinary Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['secure_url'];
      } else {
        throw Exception('Failed to upload image: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      return null;
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();

      // Navigate to login page after sign out
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF90ADFF), // Set background color
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Color(0xFF90ADFF), // Optional: Match the app bar color
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Profile Avatar
              GestureDetector(
                onTap: _uploadingImage ? null : _pickAndUploadImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _avatarUrl != null
                          ? NetworkImage(_avatarUrl!)
                          : null,
                      child: _avatarUrl == null
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: _uploadingImage
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Profile Form
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        readOnly: true, // Email is typically not editable
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bioController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Bio',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Update Profile',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Additional options
              Card(
                elevation: 2,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('Change Password'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: Navigate to change password screen
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.notifications),
                      title: const Text('Notification Settings'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: Navigate to notification settings
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip),
                      title: const Text('Privacy Settings'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: Navigate to privacy settings
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
} */
