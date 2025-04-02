import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:petpalace/Database/database.dart';
import 'package:petpalace/chat_service/chat_screen.dart';
import 'package:petpalace/chat_service/chat_service.dart';
import 'package:petpalace/constant/constant.dart';
import 'package:petpalace/widgets/lottieLoading.dart';

import '../../widgets/scheduleMeeting.dart';

class ConsultVetScreen extends StatefulWidget {
  const ConsultVetScreen({super.key});

  @override
  State<ConsultVetScreen> createState() => _ConsultVetScreenState();
}

class _ConsultVetScreenState extends State<ConsultVetScreen> {
  final DataBaseStorage _dataBaseStorage = DataBaseStorage();
  final ChatService _chatService = ChatService();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String? userName;
  String? profilepic;

  @override
  void initState() {
    super.initState();
    getUsername(currentUserId);
  }

  Future<void> getUsername(String currentUserId) async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(currentUserId)
              .get();
      if (doc.exists) {
        setState(() {
          userName = doc['name'];
          profilepic = doc["profilepic"];
        });
      }
    } catch (e) {
      print("Error fetching username: $e");
    }
  }

  void _navigateToChatScreen(
    BuildContext context,
    String receiverId,
    String name,
  ) {
    if (receiverId.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ChatPage(receiverId: receiverId, username: name),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Owner ID or email not available.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color bc = Theme.of(context).colorScheme.onPrimary;

    return Scaffold(
      backgroundColor: bc,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          buildUpperHeaderUi(),
          Padding(
            padding: const EdgeInsets.only(left: 18.0),
            child: Text("Feature Vets", style: style),
          ),
          buildUi(),
        ],
      ),
    );
  }

  Widget buildUpperHeaderUi() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.6,
          height: 80,
          padding: const EdgeInsets.all(15),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello ${userName ?? 'User'}👋',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              const Text(
                'How are you today?',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                ),
              ],
              image:
                  profilepic != null && profilepic!.isNotEmpty
                      ? DecorationImage(
                        image: NetworkImage(profilepic!),
                        fit: BoxFit.cover,
                      )
                      : null,
            ),
            child:
                profilepic == null || profilepic!.isEmpty
                    ? const Icon(Icons.person, size: 30, color: Colors.grey)
                    : null,
          ),
        ),
      ],
    );
  }

  Widget buildUi() {
    final containerColors = Theme.of(context).colorScheme.onPrimary;
    Color ic = Theme.of(context).colorScheme.primary;

    return Expanded(
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _dataBaseStorage.retrieveDataFromVet(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Lottieloading();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No vets found.'));
          }

          final vets = snapshot.data!;
          return ListView.builder(
            itemCount: vets.length,
            itemBuilder: (context, index) {
              final vet = vets[index];

              return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: containerColors,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: bc,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                        spreadRadius: 2,
                                        blurRadius: 8,
                                        offset: const Offset(
                                          0,
                                          4,
                                        ), // Shadow effect
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.star, color: ic, size: 24),
                                      const SizedBox(width: 8),
                                      Text(
                                        "0",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  vet['vet_name'] ?? 'Vet',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Specialization: ${vet['specialization'] ?? 'Vet Specialist'}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${vet['experience']} years of Experience',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Hero(
                              tag: 'vet-${vet['uid']}',
                              child: Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(vet["profileImage"]),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.pets, color: containerColors, size: 24),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                vet['services_offered'] ??
                                    'Services not specified',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.phone, color: containerColors, size: 24),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                vet['contact'] ?? 'Contact not available',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: containerColors,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                vet['clinic_address'] ??
                                    'Address not available',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                ScheduleMeeting.show(
                                  context,
                                  vet['uid'],
                                  vet['vet_name'],
                                  currentUserId,
                                  userName ?? 'User',
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'Schedule',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            FloatingActionButton(
                              onPressed: () {
                                if (vet.isNotEmpty) {
                                  String receiverId = vet['uid'];
                                  String name = vet['vet_name'];

                                  _navigateToChatScreen(
                                    context,
                                    receiverId,
                                    name,
                                  );
                                }
                              },
                              backgroundColor: Colors.white,
                              elevation: 8.0,
                              child: SvgPicture.asset(
                                'assets/icons/chat.svg',
                                color: Colors.black,
                                height: 28,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .scaleXY(
                    // Smooth zoom-in effect
                    begin: 0.7, // Start slightly scaled down
                    end: 1,
                    duration: 300.ms, // Faster than 100ms (avoids jank)
                    curve: Curves.easeOutBack, // Bouncy, playful feel
                  )
                  .fadeIn(
                    // Adds opacity transition
                    delay: 50.ms, // Slight delay after scale starts
                    duration: 250.ms,
                  )
                  .slide(
                    // Optional subtle slide
                    begin: const Offset(0, 0.2), // Minor vertical slide
                    end: Offset.zero,
                    duration: 300.ms,
                    curve: Curves.easeOutCubic,
                  );
            },
          );
        },
      ),
    );
  }
}
