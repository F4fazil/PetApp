import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:petpalace/Database/database.dart';
import 'package:petpalace/admin_panel/PetSitter_admin_panel/Petsitter_admin.dart';
import 'package:petpalace/chat_service/chat_screen.dart';
import 'package:petpalace/chat_service/chat_service.dart';
import 'package:petpalace/constant/constant.dart';

class PetSitterScreen extends StatelessWidget {
  final DataBaseStorage _dataBaseStorage = DataBaseStorage();
  final ChatService _chatService = ChatService();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  PetSitterScreen({super.key});
  void _navigateToChatScreen(
    BuildContext context,
    String receiverId,
    String name,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(receiverId: receiverId, username: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bc,
      appBar: AppBar(
        title: const Text(
          'Find a Pet Sitter',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: app_bc,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Banner
          Container(
            width: double.infinity,
            height: 150,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal, Colors.blueGrey],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Expert care for your pets!",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Trusted sitters at your service.",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Featured Pet Sitters',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          buildUI(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPetSitterPost()),
          );
        },
        label: const Text(
          "Become a Pet Sitter",
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 41, 116, 112),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget buildUI() {
    final containerColors = [
      const Color(0xFFFC766A), // Coral
      const Color(0xFFF9A825), // Mustard
      const Color(0xFF00838F),
      const Color.fromARGB(255, 99, 92, 224), // Indigo
      const Color.fromARGB(255, 75, 180, 155), // Teal
      // Deep Teal
    ];

    return Expanded(
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _dataBaseStorage.retrieveDataFroPetSitter(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Lottie.asset(
                "assets/lottie/loading.json",
                height: 200,
                width: 200,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No pet sitters found.'));
          }

          final petSitters = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: petSitters.length,
            itemBuilder: (context, index) {
              final sitter = petSitters[index];
              final cardColor =
                  containerColors[index %
                      containerColors.length]; // Cycle through colors

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                color: cardColor, // Set the card background color
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(
                              sitter["profileImage"],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      sitter['sitter_name'] ?? 'Pet Sitter',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color:
                                            Colors
                                                .white, // Adjust text color for contrast
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.white.withOpacity(0.2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.yellow,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "0",
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.9,
                                              ),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${sitter['experience']} years of experience',
                                  style: const TextStyle(
                                    color:
                                        Colors
                                            .white70, // Adjust text color for contrast
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.phone, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            sitter['contact'] ?? 'Not available',
                            style: const TextStyle(
                              fontSize: 15,
                              color:
                                  Colors
                                      .white, // Adjust text color for contrast
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              sitter['address'] ?? 'Address not available',
                              style: const TextStyle(
                                fontSize: 15,
                                color:
                                    Colors
                                        .white, // Adjust text color for contrast
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _navigateToChatScreen(
                              context,
                              sitter['uid'],
                              sitter['sitter_name'],
                            );
                          },
                          icon: const Icon(Icons.chat),
                          label: const Text("Chat"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor:
                                cardColor, // Use cardColor for button text
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
