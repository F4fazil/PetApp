import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:random_string/random_string.dart';

import '../../Database/database.dart';
import '../../constant/constant.dart';
import '../../widgets/Osm_dailoge.dart';
import '../../widgets/login_signup_btn.dart';
import '../../widgets/textfield.dart';

class BreedConnectPost extends StatefulWidget {
  const BreedConnectPost({super.key});

  @override
  State<BreedConnectPost> createState() => _BreedConnectPostState();
}

class _BreedConnectPostState extends State<BreedConnectPost>
    with SingleTickerProviderStateMixin {
  User? user = FirebaseAuth.instance.currentUser;
  bool isProcessing = false;
  final TextEditingController petName = TextEditingController();
  final TextEditingController contact = TextEditingController();
  final TextEditingController petBreed = TextEditingController();
  final TextEditingController age = TextEditingController();
  final TextEditingController price = TextEditingController();
  final TextEditingController streetNumber = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController state = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  String? address;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Pet Sitter Details',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isProcessing
          ? Center(
              child: Lottie.asset(
                "assets/lottie/upload.json",
                height: 300,
                width: 300,
              ),
            )
          : _buildUI(),
    );
  }

  Widget _buildUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickProfileImage,
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: _profileImage == null
                    ? Icon(
                        Icons.add_a_photo_outlined,
                        size: 50,
                        color: textfieldicon,
                      )
                    : ClipOval(
                        child: Image.file(
                          _profileImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          MyTextField(
            controller: petName,
            icon: Icon(Icons.pets, color: textfieldicon),
            hintText: 'Pet Name',
          ),
          const SizedBox(height: 15),
          MyTextField(
            controller: contact,
            icon: Icon(Icons.phone, color: textfieldicon),
            hintText: 'Contact',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 15),
          MyTextField(
            controller: petBreed,
            icon: Icon(Icons.category, color: textfieldicon),
            hintText: 'Pet Breed',
          ),
          const SizedBox(height: 15),
          MyTextField(
            controller: age,
            icon: Icon(Icons.calendar_today, color: textfieldicon),
            hintText: 'Pet Age',
          ),
          const SizedBox(height: 15),
          MyTextField(
            controller: price,
            icon: Icon(Icons.attach_money, color: textfieldicon),
            hintText: 'Price',
          ),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _showAddressBottomSheet(context),
              icon: const Icon(Icons.add_location_alt, color: Colors.white),
              label: const Text(
                'Add Your Address',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: textfieldicon,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
          if (address != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Wrap(children: [
                Text(
                  'Address: $address',
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ]),
            ),
          const SizedBox(height: 20),
          Center(
            child: MyButton(
              onPressed: () async {
                if (user != null) {
                  uploadProfileImage(user!.uid);
                } else {
                  print("User is not logged in.");
                }
              },
              text: 'Post Details',
            ),
          ),
        ],
      ),
    );
  }

  void _showAddressBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyTextField(
                controller: streetNumber,
                hintText: 'Street Number',
                icon: Icon(Icons.streetview, color: textfieldicon),
              ),
              const SizedBox(height: 15),
              MyTextField(
                controller: city,
                hintText: 'City',
                icon: Icon(Icons.location_city, color: textfieldicon),
              ),
              const SizedBox(height: 15),
              MyTextField(
                controller: state,
                hintText: 'State/Province',
                icon: Icon(Icons.map, color: textfieldicon),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: textfieldicon,
                ),
                onPressed: () {
                  setState(() {
                    address =
                        '${streetNumber.text}, ${city.text}, ${state.text}';
                  });
                  Navigator.pop(context);
                },
                child: const Text(
                  'Save Address',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickProfileImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void uploadProfileImage(String userId) async {
    if (_profileImage == null) {
      OsmDailogue(context).showSnackBar(
        "Please select a profile picture.",
      );
      return;
    }

    try {
      var id = randomAlphaNumeric(10);
      Reference profileImageRef =
          FirebaseStorage.instance.ref().child("profile_pic").child(id);
      UploadTask upload = profileImageRef.putFile(_profileImage!);
      String profileImageUrl = await (await upload).ref.getDownloadURL();

      if (petName.text.isNotEmpty &&
          contact.text.isNotEmpty &&
          petBreed.text.isNotEmpty &&
          city.text.isNotEmpty &&
          price.text.isNotEmpty) {
        Map<String, dynamic> temp = {
          "profileImage": profileImageUrl,
          "pet_name": petName.text,
          "contact": contact.text,
          "pet_breed": petBreed.text,
          "age": age.text,
          "price": price.text,
          "address": address,
          "uid": userId,
        };
        print("Data to be added: $temp");
        await DataBaseStorage().add_data_to_SameBreed(temp);
        setState(() {
          isProcessing = true;
          Future.delayed(const Duration(seconds: 5), () {
            setState(() {
              isProcessing = false;
            });
          });
        });
        print("Saved to PetSitter");
      } else {
        OsmDailogue(context).showSnackBar(
          "Failed Please fill all the fields.",
        );
      }
    } catch (e) {
      print("Error uploading profile image: $e");
      OsmDailogue(context).showSnackBar(
        "Failed An error occurred while uploading the image.",
      );
    }
  }
}
