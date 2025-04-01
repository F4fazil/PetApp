import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:petpalace/Database/database.dart';
import 'package:petpalace/admin_panel/SameBreed_admin.dart';
import 'package:petpalace/chat_service/chat_screen.dart';
import 'package:petpalace/constant/constant.dart';

class BreedConnectScreen extends StatefulWidget {
  const BreedConnectScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BreedConnectScreenState createState() => _BreedConnectScreenState();
}

class _BreedConnectScreenState extends State<BreedConnectScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel(); // Cancel previous timer if still running
    }

    _debounce = Timer(const Duration(seconds: 3), () {
      // Perform search after 3 seconds of inactivity
      setState(() {
        // No need to manually trigger the search; the StreamBuilder will automatically rebuild
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: bc,
      appBar: AppBar(
        title: const Text("BreedConnect"),
        centerTitle: true,
        backgroundColor: app_bc,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {});
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search pets by breed or name',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0Xff66cdaa),
                    width: 0.7,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0Xff66cdaa), width: 1),
                ),
                fillColor: Colors.white.withOpacity(0.7),
                filled: true,
              ),
            ),
          ),

          // Data Display
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: DataBaseStorage().retrieveDataFromSameBreed(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Lottie.asset(
                      "assets/lottie/loading.json",
                      height: screenHeight * 0.3,
                      width: screenWidth * 0.6,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No pets found'));
                }

                // Filter data based on search query
                final searchText = _searchController.text.toLowerCase();
                final pets =
                    snapshot.data!.where((pet) {
                      final name =
                          pet['pet_name']?.toString().toLowerCase() ?? '';
                      final breed =
                          pet['pet_breed']?.toString().toLowerCase() ?? '';
                      return name.contains(searchText) ||
                          breed.contains(searchText);
                    }).toList();

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        screenWidth > 600 ? 2 : 1, // Responsive grid
                    mainAxisSpacing: 6.0,
                    crossAxisSpacing: 6.0,
                    childAspectRatio:
                        screenWidth > 600
                            ? 0.9
                            : 0.8, // Responsive aspect ratio
                  ),
                  padding: EdgeInsets.all(
                    screenWidth * 0.04,
                  ), // Responsive padding
                  itemCount: pets.length,
                  itemBuilder: (context, index) {
                    final pet = pets[index];
                    return PetCard(pet: pet);
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BreedConnectPost()),
          );
        },
        label: const Text(
          "Post Your Pet",
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 41, 116, 112),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class PetCard extends StatelessWidget {
  final Map<String, dynamic> pet;

  const PetCard({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final List<Color> cardColors = [
      const Color(0xFF6A1B9A).withOpacity(0.8), // Purple
      const Color(0xFFAB47BC).withOpacity(0.8), // Light Purple
      const Color(0xFF26A69A).withOpacity(0.8), // Teal
      const Color(0xFF42A5F5).withOpacity(0.8), // Blue
    ];
    final Color cardColor = cardColors[pet.hashCode % cardColors.length];

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cardColor, cardColor.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet Image with Favorite Button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16.0),
                  ),
                  child: Image.network(
                    pet['profileImage'] ??
                        'https://via.placeholder.com/150', // Default placeholder
                    height: screenHeight * 0.24, // Responsive height
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: screenHeight * 0.25, // Responsive height
                        width: double.infinity,
                        color: Colors.grey.shade300, // Neutral background color
                        child: const Icon(
                          Icons.pets,
                          color: Colors.white,
                          size: 50,
                        ), // Pet icon
                      );
                    },
                  ),
                ),
              ],
            ),

            // Pet Info
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pet Name and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pet['pet_name'] ?? 'Unknown',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045, // Responsive font size
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '4.5', // Replace with actual rating if available
                            style: TextStyle(
                              fontSize:
                                  screenWidth * 0.04, // Responsive font size
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Breed
                  _buildInfoRow('Breed', pet['pet_breed'] ?? 'Unknown Breed'),
                  const SizedBox(height: 8),

                  // Address
                  _buildInfoRow('Address', pet['address'] ?? 'Unknown Address'),
                  const SizedBox(height: 8),

                  // Age
                  _buildInfoRow('Age', pet['age'] ?? 'Unknown Age'),
                  const SizedBox(height: 8),

                  // Contact
                  _buildInfoRow('Contact', pet['contact'] ?? 'N/A'),
                  const SizedBox(height: 12),

                  // Chat Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _navigateToChatScreen(
                          context,
                          pet['uid'] ?? '',
                          "Chat",
                        );
                      },
                      icon: const Icon(Icons.chat, color: Colors.white),
                      label: const Text(
                        "Chat",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build info rows
  Widget _buildInfoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

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
}
