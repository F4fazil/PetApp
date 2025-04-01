import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../admin_panel/vet_admin_panel/vet_admin.dart';
import 'profile_screens/Meetings.dart';
import 'profile_screens/Mypost.dart';
import 'profile_screens/vet_mettings.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _avatarScaleAnimation;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  String uid = FirebaseAuth.instance.currentUser!.uid;
  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _avatarScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    try {
      // Step 1: Pick an image from the gallery
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile == null) return; // User canceled the picker

      // Step 2: Upload the image to Firebase Storage
      File imageFile = File(pickedFile.path);
      String fileName =
          'profile_images/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageReference = FirebaseStorage.instance.ref().child(
        fileName,
      );
      UploadTask uploadTask = storageReference.putFile(imageFile);

      // Wait for the upload to complete
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadURL = await taskSnapshot.ref.getDownloadURL();

      // Step 3: Save the download URL in Firestore
      await FirebaseFirestore.instance.collection("users").doc(uid).update({
        "profilepic": downloadURL,
      });

      // Step 4: Update the UI
      setState(() {
        _profileImage = imageFile;
      });

      // Optional: Save the image path locally using SharedPreferences
      await saveProfile("profile_path", pickedFile.path);

      print("Profile image uploaded successfully!");
    } catch (e) {
      print("Error uploading profile image: $e");
    }
  }

  Future<void> saveProfile(String key, String path) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(key, path);
  }

  Future<void> _loadProfileImage() async {
    final String? path = await fetchProfile('profile_path');
    if (path != null) {
      setState(() {
        _profileImage = File(path);
      });
    }
  }

  Future<String?> fetchProfile(String key) async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(key);
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String? email = user?.email?.trim();
    String? namePart = email?.split('@')[0] ?? 'User';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(namePart, constraints.maxWidth),
                const SizedBox(height: 20),
                _buildSettingsList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(String namePart, double maxWidth) {
    return AnimatedBuilder(
      animation: _animationController,
      builder:
          (context, child) => Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickProfileImage,
                  child: ScaleTransition(
                    scale: _avatarScaleAnimation,
                    child: CircleAvatar(
                      radius: maxWidth * 0.15,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryFixed,
                      child:
                          _profileImage != null
                              ? ClipOval(
                                child: Image.file(
                                  _profileImage!,
                                  fit: BoxFit.cover,
                                  width: maxWidth * 0.3,
                                  height: maxWidth * 0.3,
                                ),
                              )
                              : Icon(
                                Icons.add_a_photo_outlined,
                                size: maxWidth * 0.1,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  namePart,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  FirebaseAuth.instance.currentUser?.email ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildSettingsList() {
    final List<Map<String, dynamic>> settingsItems = [
      {'icon': Icons.person, 'title': 'Vet Meetings'},
      {'icon': Icons.calendar_today, 'title': 'Meetings Schedule'},
      {'icon': Icons.bookmark_added, 'title': 'My Post'},
      {'icon': Icons.info, 'title': 'Become a Vet'},
      {'icon': Icons.exit_to_app, 'title': 'Logout'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: settingsItems.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final item = settingsItems[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(
                item['icon'],
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                item['title'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: () {
                switch (index) {
                  case 0:
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const VetMeetingsScreen(),
                      ),
                    );
                    break;
                  case 1:
                    // Navigate to Sell Your Property screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MeetingsScreen(),
                      ),
                    );
                    break;
                  case 2:
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MyPostScreen(),
                      ),
                    );

                    break;
                  case 3:
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AddVetPost(),
                      ),
                    );
                    break;
                  case 4:
                    FirebaseAuth.instance.signOut();
                    break;
                }
              },
            ),
          );
        },
      ),
    );
  }
}
