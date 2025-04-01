import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:petpalace/payment/paymentMethod.dart';
import '../chat_service/chat_screen.dart';
import '../chat_service/chat_service.dart';
import '../widgets/login_signup_btn.dart'; // Import for SVG icons

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> homeData;

  const DetailPage({super.key, required this.homeData});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final ChatService _chatService = ChatService(); // Update if needed
  final StripePaymentService _payment = StripePaymentService();
  final PageController _pageController = PageController();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  int _currentPage = 0;
  var uid;
  var gmail;

  @override
  void initState() {
    super.initState();
    uid = widget.homeData["uid"];
    print(uid);
    gmail = widget.homeData["userEmail"];
    print(gmail);
    print("uid");
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  void _buyProperty(BuildContext context) async {
    // Ensure 'price' is a double by parsing the string value
    double price;
    try {
      price = double.parse(widget.homeData['price'].toString());
    } catch (e) {
      print("Price Parsing Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid price format')));
      return;
    }

    // Calculate the advance amount (5% of the price)
    double advanceAmount = price * 0.05;

    try {
      // Make the payment using Stripe
      await _payment.makePayment(
        context,
        advanceAmount.toStringAsFixed(2),
        "USD",
      );
    } catch (e) {
      print("Payment Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Payment failed: $e')));
      return;
    }
  }

  Stream<QuerySnapshot> _fetchUsers() {
    User? user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('users')
        .where('uid', isNotEqualTo: user?.uid)
        .snapshots();
  }

  void _navigateoChatScreen(
    BuildContext context,
    String receiverId,
    String name,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChatPage(
              // receiverEmail: receiverEmail!,
              receiverId: receiverId,
              username: name.toString(),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Explicitly cast to List<String>
    final List<String> images = List<String>.from(widget.homeData['images']);

    return Scaffold(
      appBar: AppBar(title: Text(widget.homeData['name'] ?? 'Pet Details')),
      body: Stack(
        children: [
          // Property details content
          Column(
            children: [
              // Image PageView
              SizedBox(
                height:
                    MediaQuery.of(context).size.height *
                    0.5, // Half height of the screen
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Hero(
                      tag: 'image-${images[index]}',
                      child: Material(
                        child: Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          width:
                              MediaQuery.of(context).size.width, // Full width
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Page indicator
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: Text(
                    '${_currentPage + 1}/${images.length}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10.0,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PKR ${widget.homeData['price']}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Location: ${widget.homeData['location'] ?? 'No location'}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.homeData['description'] ?? 'No description',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: MyButton(
                          onPressed: () {
                            _payment.makePayment(
                              context,
                              widget.homeData['price'],
                              "usd",
                            );
                          },
                          text: 'Buy this Pet',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Beautiful UI for communication buttons
          Positioned(
            bottom: 20.0,
            right: 20.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10.0),
                // chatpage
                FloatingActionButton(
                  onPressed: () {
                    if (widget.homeData.isNotEmpty) {
                      // Example email
                      String receiverId = widget.homeData['uid'];
                      String name = "Chat";

                      _navigateoChatScreen(context, receiverId, name);
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
          ),
        ],
      ),
    );
  }

  // Widget _buildUserList() {
  //   return StreamBuilder<QuerySnapshot>(
  //     stream: FirebaseFirestore.instance.collection("users").snapshots(),
  //     builder: (context, snapshot) {
  //       if (snapshot.hasError) {
  //         return const Center(child: Text("Error loading users."));
  //       }
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return Center(
  //           child: Lottie.asset("assets/lottie/loading.json",
  //               height: 200, width: 200),
  //         );
  //       }
  //       return ListView.builder(
  //         shrinkWrap: true,
  //         itemCount: snapshot.data!.docs.length,
  //         itemBuilder: (BuildContext context, int index) {
  //           DocumentSnapshot userData = snapshot.data!.docs[index];
  //           return Dismissible(
  //             key: Key(userData.id), // Unique identifier for each item
  //             direction:
  //                 DismissDirection.endToStart, // Swipe from right to left
  //             onDismissed: (direction) {
  //               // Remove the user from Firestore (or your database) when swiped
  //               FirebaseFirestore.instance
  //                   .collection('users')
  //                   .doc(userData.id)
  //                   .delete();

  //               // Show a snackbar or any feedback on successful delete
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(content: Text("${userData['name']} deleted")),
  //               );
  //             },
  //             background: Container(
  //               color: Colors.red, // Background color when swiped
  //               alignment: Alignment.centerRight,
  //               padding: const EdgeInsets.symmetric(horizontal: 20.0),
  //               child: const Icon(Icons.delete,
  //                   color: Colors.white), // Delete icon
  //             ),
  //             child: Column(
  //               children: [
  //                 Container(
  //                   margin: const EdgeInsets.symmetric(vertical: 8.0),
  //                   decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     borderRadius: BorderRadius.circular(12.0),
  //                   ),
  //                   child: userListItem(userData),
  //                 ),
  //                 if (index !=
  //                     snapshot.data!.docs.length -
  //                         1) // Prevent divider after the last item
  //                   const Padding(
  //                     padding: EdgeInsets.only(left: 75.0),
  //                     child: Divider(
  //                       color: Colors.grey,
  //                       thickness: 0.4,
  //                       height:
  //                           10.0, // Adjust the space above and below the divider
  //                     ),
  //                   ),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  // Widget userListItem(DocumentSnapshot document) {
  //   Map<String, dynamic> data = document.data() as Map<String, dynamic>;
  //   String? name = data['name'] as String?;
  //   String? userEmail = data["userEmail"] as String?;

  //   if (firebaseAuth.currentUser?.email != userEmail) {
  //     return ListTile(
  //       onTap: () {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => ChatPage(
  //               // receiverEmail: userEmail!,
  //               receiverId: data["uid"],
  //               username: name.toString(),
  //             ),
  //           ),
  //         );
  //       },
  //       leading: CircleAvatar(
  //           radius:
  //               32.0, // Adjust this value to change the size (similar to WhatsApp size)
  //           backgroundColor: app_bc,
  //           child: const Icon(
  //             Icons.person,
  //             size: 25,
  //           )),
  //       title: Padding(
  //         padding: const EdgeInsets.only(bottom: 5.0, left: 10),
  //         child: Text(
  //           name ?? "Unknown",
  //           style: const TextStyle(
  //             fontWeight: FontWeight.bold,
  //             color: Colors.black87,
  //           ),
  //         ),
  //       ),
  //       subtitle: const Padding(
  //         padding: EdgeInsets.only(left: 11.0),
  //         child: Text(
  //           "Tap to view messages",
  //           style: TextStyle(color: Colors.grey),
  //         ),
  //       ),
  //     );
  //   }
  //   return Container();
  // }
}
