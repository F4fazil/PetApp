import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:petpalace/screens/feature_screens/buy_and_sell.dart';
import 'package:petpalace/screens/feature_screens/sameBreedScreen.dart';

import '../Emergency_sos/Sos_button.dart';
import '../constant/constant.dart';
import '../notification/NotificationScreen.dart';
import '../widgets/curvecut_conatiner.dart';
import 'Seacrch_Screen.dart';
import 'feature_screens/Consulting_vet.dart';
import 'feature_screens/pet_food.dart';
import 'feature_screens/pet_screen.dart';
import 'main_screen_categeories/categouries.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Map<String, dynamic>> temp;
  Map<int, bool> favoriteStatus = {};
  final TextEditingController _searchController = TextEditingController();
  final Color selectedColor = app_bc;
  final Color unselectedColor = Colors.blueGrey.shade50;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool isFav = false;
  final List<Map<String, String>> categories = [
    {'img': 'assets/images/doctor.png', 'sub_header': 'Consult a Vet'},
    {'img': 'assets/images/petsitter1.png', 'sub_header': 'Find Pet sitters'},
    {'img': 'assets/images/cash.png', 'sub_header': 'Buy and sell'},
    {'img': 'assets/images/pets.png', 'sub_header': 'BreedFood'},
    {'img': 'assets/images/gps-tracker.png', 'sub_header': 'GPS Tracker'},
    {'img': 'assets/images/petsitter.png', 'sub_header': 'BreedConnect'},
  ];

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);
    _firebaseMessaging.requestPermission();

    // Get the token for this device
    _firebaseMessaging.getToken().then((String? token) {
      assert(token != null);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {}
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    await Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    Color iconBc = Theme.of(context).colorScheme.onPrimary;
    final screenHeight = MediaQuery.of(context).size.height;
    final circularContainerHeight = screenHeight * 0.65;
    return Scaffold(
      backgroundColor: iconBc,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // header
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Container(
              height: circularContainerHeight, // 35% of screen height
              width: MediaQuery.of(context).size.width, // Make it circular
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: CustomPaint(
                painter: CurvedSplitPainter(
                  primaryContainerColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  tertiaryFixedVariantColor:
                      Theme.of(context).colorScheme.onTertiaryFixedVariant,
                ),
              ),
            ),
          ),

          Positioned(
            top: circularContainerHeight * 0.1,
            left: 27,
            child: Image.asset(
              "assets/icons/pawprint.png",
              color: iconBc, // Your desired color
              colorBlendMode: BlendMode.srcIn, // Preserves transparency
              height: 40,
              width: 40,
            ),
          ),

          Positioned(
            top: circularContainerHeight * 0.09,
            right: 27,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.notifications, size: 35),
            ),
          ),

          Positioned(
            top: circularContainerHeight * 0.22,
            right: 33,
            child: SOSButton(),
          ),

          Positioned(
            top: circularContainerHeight * 0.20,
            left: 19,
            child: const Text(
              "For Pets,\n With Love.",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).size.height * 0.23,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 600,
              decoration: BoxDecoration(
                color: iconBc,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 20),
                itemCount: (categories.length / 2).ceil(),
                itemBuilder: (context, index) {
                  // Two items per row
                  final firstItem = categories[index * 2];
                  final secondItem =
                      (index * 2 + 1 < categories.length)
                          ? categories[index * 2 + 1]
                          : null;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CategouriesContainer(
                          img: firstItem['img']!,
                          sub_header: firstItem['sub_header']!,
                          onTap: () {
                            _handleCategoryTap(
                              context,
                              firstItem['sub_header']!,
                            );
                          },
                        ),
                        if (secondItem != null)
                          CategouriesContainer(
                            img: secondItem['img']!,
                            sub_header: secondItem['sub_header']!,
                            onTap: () {
                              _handleCategoryTap(
                                context,
                                secondItem['sub_header']!,
                              );
                            },
                          ),
                        if (secondItem == null)
                          const Spacer(), // Align single-item rows properly
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCategoryTap(BuildContext context, String category) {
    if (category == 'Consult a Vet') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ConsultVetScreen()),
      );
    } else if (category == 'Find Pet sitters') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PetSitterScreen()),
      );
      // LocalNotification().showNotification();
    } else if (category == 'Buy and sell') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BuyAndSell()),
      );
    } else if (category == 'BreedFood') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AnimalListScreen()),
      );
    } else if (category == 'GPS Tracker') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GoogleMapScreen()),
      );
    } else if (category == 'BreedConnect') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BreedConnectScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No action defined for $category')),
      );
    }
  }
}
