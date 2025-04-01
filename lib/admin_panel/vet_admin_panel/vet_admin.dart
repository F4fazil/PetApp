import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petpalace/constant/constant.dart';
import 'package:random_string/random_string.dart';

import '../../Database/database.dart';
import '../../widgets/Osm_dailoge.dart';
import '../../widgets/login_signup_btn.dart';
import '../../widgets/textfield.dart';

class AddVetPost extends StatefulWidget {
  const AddVetPost({super.key});

  @override
  State<AddVetPost> createState() => _AddVetPostState();
}

class _AddVetPostState extends State<AddVetPost>
    with SingleTickerProviderStateMixin {
  User? user = FirebaseAuth.instance.currentUser;
  bool isProcessing = false;
  final vet_name = TextEditingController();
  final contact = TextEditingController();
  final available_hours = TextEditingController();
  final experience = TextEditingController();
  final specialization = TextEditingController();
  final services_offered = TextEditingController();
  final clinic_address = TextEditingController();
  final consultation_fee = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  late AnimationController _controller;
  File? _profileImage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Vet Details',
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
      body:
          isProcessing
              ? Center(
                child: Lottie.asset(
                  "assets/lottie/upload.json",
                  height: 300,
                  width: 300,
                ),
              )
              : buildui(),
    );
  }

  Widget buildui() {
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
                  color: Colors.grey.shade200,
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
                child:
                    _profileImage == null
                        ? Icon(
                          Icons.add_a_photo_outlined,
                          size: 50,
                          color: textfieldicon,
                        )
                        : ClipOval(
                          child: Image.file(_profileImage!, fit: BoxFit.cover),
                        ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          MyTextField(
            controller: vet_name,
            icon: Icon(Icons.person, color: textfieldicon),
            hintText: 'Vet Name',
          ),
          const SizedBox(height: 15),
          MyTextField(
            controller: contact,
            icon: Icon(Icons.phone, color: textfieldicon),
            hintText: 'Contact Number',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 15),
          MyTextField(
            controller: available_hours,
            icon: Icon(Icons.access_time, color: textfieldicon),
            hintText: 'Available Hours',
            keyboardType: TextInputType.datetime,
          ),
          const SizedBox(height: 15),
          MyTextField(
            controller: experience,
            icon: Icon(Icons.work, color: textfieldicon),
            hintText: 'Years of Experience',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 15),
          MyTextField(
            controller: specialization,
            icon: Icon(Icons.medical_services, color: textfieldicon),
            hintText: 'Specialization',
          ),
          const SizedBox(height: 15),
          MyTextField(
            controller: services_offered,
            icon: Icon(Icons.list_alt, color: textfieldicon),
            hintText: 'Services Offered',
          ),
          const SizedBox(height: 15),
          MyTextField(
            controller: clinic_address,
            icon: Icon(Icons.location_on, color: textfieldicon),
            hintText: 'Clinic Address',
            keyboardType: TextInputType.streetAddress,
          ),
          const SizedBox(height: 15),
          MyTextField(
            controller: consultation_fee,
            icon: Icon(Icons.attach_money, color: textfieldicon),
            hintText: 'Consultation Fee',
          ),
          const SizedBox(height: 15),
          const SizedBox(height: 30),
          Center(
            child: MyButton(
              onPressed: () async {
                if (user != null) {
                  uploadProfileImage(user!.uid.toString());
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

  Future<void> _pickProfileImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void uploadProfileImage(String userId) async {
    if (_profileImage == null) {
      OsmDailogue(
        context,
      ).showSnackBar("Failed Please select a profile picture.");
      return;
    }

    try {
      var id = randomAlphaNumeric(10);
      Reference profileImageRef = FirebaseStorage.instance
          .ref()
          .child("profile_pic")
          .child(id);
      UploadTask upload = profileImageRef.putFile(_profileImage!);
      String profileImageUrl = await (await upload).ref.getDownloadURL();

      if (vet_name.text.isNotEmpty &&
          contact.text.isNotEmpty &&
          available_hours.text.isNotEmpty &&
          experience.text.isNotEmpty &&
          specialization.text.isNotEmpty &&
          services_offered.text.isNotEmpty &&
          clinic_address.text.isNotEmpty &&
          consultation_fee.text.isNotEmpty) {
        Map<String, dynamic> vetData = {
          "profileImage": profileImageUrl,
          "vet_name": vet_name.text,
          "contact": contact.text,
          "available_hours": available_hours.text,
          "experience": experience.text,
          "specialization": specialization.text,
          "services_offered": services_offered.text,
          "clinic_address": clinic_address.text,
          "consultation_fee": consultation_fee.text,
          "uid": userId,
        };
        print("Data to be added: $vetData");
        await DataBaseStorage().add_data_to_Vet(vetData);
        setState(() {
          isProcessing = true;
          Future.delayed(const Duration(seconds: 6), () {
            setState(() {
              isProcessing = false; // Hide the animation after 2 seconds
            });
          });
        });

        print("Saved to Vet");
      } else {
        OsmDailogue(context).showSnackBar("Failed Please fill all the fields.");
      }
    } catch (e) {
      print("Error uploading profile image: $e");
      OsmDailogue(
        context,
      ).showSnackBar("Failed An error occurred while uploading the image.");
    }
  }
}
