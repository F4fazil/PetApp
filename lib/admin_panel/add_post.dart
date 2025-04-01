import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

import '../Database/database.dart';
import '../constant/constant.dart';
import '../widgets/ExploreTextField.dart';
import '../widgets/Osm_dailoge.dart';
import '../widgets/login_signup_btn.dart';
import '../widgets/textfield.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> with SingleTickerProviderStateMixin {
  User? user = FirebaseAuth.instance.currentUser;
  final pet_type = TextEditingController();
  final price = TextEditingController();
  final pet_breed = TextEditingController();
  final desc = TextEditingController();
  final streetNumber = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final DateTime _dateTime = DateTime.now();
  final List<String> _type = [
    "Cat",
    "Dog",
  ];
  final List<File> _imageFiles = [];
  AnimationController? _controller;
  String? address;
  String? name;

  @override
  void initState() {
    super.initState();
    getCurrentUsername();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<String> getCurrentUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }

    try {
      var userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();
      setState(() {
        name = userDoc.data()?["name"];
      });
      print(name);

      return userDoc.data()?['name'] ?? 'No Username Found';
    } catch (e) {
      print('Error fetching username: $e');
      return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Pet details',
          style: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: buildui(),
    );
  }

  Widget buildui() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Stack(children: [
                  GestureDetector(
                    onTap: () {
                      if (_controller != null) {
                        _controller!
                            .forward()
                            .then((value) => _controller!.reverse());
                      }
                      _pickImages();
                    },
                    child: Center(
                      child: ScaleTransition(
                        scale: _controller != null
                            ? Tween(begin: 1.0, end: 1.2).animate(
                                CurvedAnimation(
                                  parent: _controller!,
                                  curve: Curves.easeInOut,
                                ),
                              )
                            : const AlwaysStoppedAnimation(1.0),
                        child: Container(
                          height: MediaQuery.of(context).size.height / 8,
                          width: MediaQuery.of(context).size.width / 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(Icons.add_a_photo_outlined,
                              size: 50, color: textfieldicon),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 15),
              _buildImageGrid(),
              const SizedBox(height: 15),
              const Row(
                children: [
                  SizedBox(
                    width: 23,
                  ),
                  Text("Pet Type"),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ExploreTextField(
                      controller: pet_type,
                      suggestions: _type,
                      hinttext: "Select Pet type",
                      svgIconPath: 'assets/icons/pawprint.png',
                    ),
                  ),
                ],
              ),
              const Row(
                children: [
                  SizedBox(width: 20),
                  Text("Price"),
                  SizedBox(width: 145),
                  Text("Pet Breed"),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 12,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2.1,
                    child: MyTextField(
                      controller: price,
                      icon: Icon(
                        Icons.money,
                        color: textfieldicon,
                      ),
                      hintText: '',
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2.1,
                    child: MyTextField(
                      controller: pet_breed,
                      icon: Icon(
                        Icons.pets,
                        color: textfieldicon,
                      ),
                      hintText: '',
                    ),
                  ),
                ],
              ),
              // description
              Padding(
                padding: const EdgeInsets.only(
                    top: 8, bottom: 8, left: 16, right: 16),
                child: TextField(
                  controller: desc,
                  maxLines: null,
                  minLines: 5,
                  decoration: InputDecoration(
                      iconColor: textfield_border_color,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: app_bc, width: 0.8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: app_bc, width: 1.2),
                      ),
                      fillColor: Colors.white.withOpacity(0.3),
                      filled: true,
                      hintText: "Help Us Get to Know Your Pet."),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              // adress button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddressBottomSheet(context),
                  icon: const Icon(Icons.add_location_alt, color: Colors.white),
                  label: const Text(
                    'Add Your Address',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 41, 116, 112),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
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
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 30),
                child: MyButton(
                  onPressed: () async {
                    if (user != null) {
                      uploadImages(user!.uid.toString());
                      OsmDailogue(context).showSnackBar(
                        "Success Posted",
                      );
                      print("upload from here.");
                    } else {
                      print("User is not logged in.");
                    }
                  },
                  text: 'Proceed',
                ),
              ),
            ],
          ),
        );
      },
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
                  backgroundColor: Colors.teal.shade300,
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

  Widget _buildImageGrid() {
    return _imageFiles.isNotEmpty
        ? GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: _imageFiles.length,
            itemBuilder: (context, index) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: GestureDetector(
                  onLongPress: () {
                    setState(() {
                      _imageFiles.removeAt(index);
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: FileImage(_imageFiles[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        : Container();
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();

    setState(() {
      _imageFiles.addAll(pickedFiles.map((file) => File(file.path)).toList());
    });
  }

  void uploadImages(String userid) async {
    List<String> downloadUrls = [];
    for (File image in _imageFiles) {
      var id = randomAlphaNumeric(10);
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child("pic").child(id);
      UploadTask upload = firebaseStorageRef.putFile(image);
      var downloadurl = await (await upload).ref.getDownloadURL();
      downloadUrls.add(downloadurl);
    }
    if (downloadUrls.isNotEmpty &&
        pet_type.text.isNotEmpty &&
        price.text.isNotEmpty &&
        desc.text.isNotEmpty) {
      Map<String, dynamic> addItem = {
        "images": downloadUrls,
        "pet_type": pet_type.text,
        "location": address,
        "price": price.text,
        "description": desc.text,
        "pet_breed": pet_breed.text,
        "uid": userid,
        "name": name,
        "TimeStamp": _dateTime
      };

      if (pet_type.text == "Cat") {
        await DataBaseStorage().add_data_to_Cat(addItem);
        await DataBaseStorage().addNotification(addItem);
        OsmDailogue(context).showSnackBar("Your post posted!");
      } else if (pet_type.text == "Dog") {
        await DataBaseStorage().add_data_to_Dog(addItem);
        await DataBaseStorage().addNotification(addItem);
        OsmDailogue(context).showSnackBar("Your post posted!");
      }
    }
  }
}
