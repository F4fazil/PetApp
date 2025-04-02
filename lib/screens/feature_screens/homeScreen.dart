// bottom navigation
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:petpalace/constant/constant.dart';
import 'package:petpalace/screens/FaviouriteScreens.dart';
import 'package:petpalace/screens/ProfileScreen.dart';
import 'package:petpalace/screens/chatScreen.dart';
import 'package:petpalace/screens/homepage.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const ChatScreen(),
    const FavoritesPage(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color iconBc = Theme.of(context).colorScheme.onPrimary;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      resizeToAvoidBottomInset: false,
      body: SlidingUpPanel(
        minHeight: 0, // Minimum height when panel is collapsed
        maxHeight:
            MediaQuery.of(context).size.height *
            0.3, // Adjust the height as needed
        panel: Container(
          color: bc,
          child: const Center(child: Text('Sliding Panel Content')),
        ),
        body: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 10,
          ), // Add margin from left, right, and bottom
          height: 70, // Set a fixed height to make the container consistent
          decoration: BoxDecoration(
            color:
                Theme.of(context)
                    .colorScheme
                    .primary, // Background color for the navigation bar
            borderRadius: BorderRadius.circular(30), // Make it circular
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.onPrimary,
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4), // Shadow effect
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              30,
            ), // Ensures the BottomNavigationBar is also rounded
            child: BottomNavigationBar(
                  backgroundColor: iconBc,
                  showSelectedLabels: false, // Hide selected labels
                  showUnselectedLabels: false, // Hide unselected labels
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      backgroundColor: iconBc,
                      icon: const Icon(Icons.pentagon_outlined),
                      activeIcon: const Icon(Icons.pentagon),
                      label: "", // Empty string instead of null
                    ),
                    BottomNavigationBarItem(
                      icon: chatIconWithIndicator(),
                      activeIcon: const Icon(Icons.chat),
                      label: "", // Empty string instead of null
                      backgroundColor: iconBc,
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.favorite_border_outlined),
                      activeIcon: const Icon(Icons.favorite_sharp),
                      label: "", // Empty string instead of null
                      backgroundColor: iconBc,
                    ),
                    BottomNavigationBarItem(
                      backgroundColor: iconBc,
                      icon: const Icon(Icons.person_2_outlined),
                      activeIcon: const Icon(Icons.person),
                      label: "", // Empty string instead of null
                    ),
                  ],
                  currentIndex: _selectedIndex,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.black54,
                  iconSize: 30.0,
                  onTap: _onItemTapped,
                )
                .animate()
                .scaleXY(
                  begin: 0,
                  end: 1,
                  delay: const Duration(milliseconds: 400),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                )
                .slide(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                  delay: 1100.ms,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                ),
          ),
        ),
      ),
    );
  }

  Widget chatIconWithIndicator() {
    final currentUserId = _firebaseAuth.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore
              .collection("chat_rooms")
              .where('participants', arrayContains: currentUserId)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Icon(Icons.chat);

        int totalUnread = 0;

        for (var doc in snapshot.data!.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          int unreadCount = data['unread_messages'][currentUserId] ?? 0;
          totalUnread += unreadCount;
        }

        return Stack(
          children: [
            const Icon(Icons.chat_bubble_outline_outlined),
            if (totalUnread > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    totalUnread.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
