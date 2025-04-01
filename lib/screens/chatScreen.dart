import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petpalace/constant/constant.dart';
import 'package:petpalace/widgets/lottieLoading.dart';
import '../chat_service/chat_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var otherUserId;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    Color iconBc = Theme.of(context).colorScheme.onPrimary;
    Color appbarColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "💬 Messages",
          style: GoogleFonts.poppins(
            fontSize: 22,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        centerTitle: true,
        backgroundColor: appbarColor,
        elevation: 4,
      ),
      body: Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: _buildUserList(),
      ),
      backgroundColor: iconBc,
    );
  }

  Widget _buildUserList() {
    final currentUserId = firebaseAuth.currentUser!.uid;
    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore
              .collection("chat_rooms")
              .where('participants', arrayContains: currentUserId)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading chats."));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Lottieloading();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No chats found."));
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot chatRoomDoc = snapshot.data!.docs[index];
            List<String> userIds = List<String>.from(
              chatRoomDoc["participants"],
            );
            String otherUserId = userIds.firstWhere(
              (id) => id != FirebaseAuth.instance.currentUser!.uid,
            );

            return FutureBuilder<Map<String, dynamic>?>(
              future: getUserInfo(otherUserId),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Text("");
                }
                if (!userSnapshot.hasData) {
                  return const ListTile(title: Text("User not found"));
                }

                Map<String, dynamic>? userData = userSnapshot.data;
                String currentUserId = FirebaseAuth.instance.currentUser!.uid;
                String lastMessage =
                    chatRoomDoc['last_message'] ?? 'No messages yet';
                String username = userData!["name"] ?? "Unknown";

                int totalUnread = 0;

                for (var doc in snapshot.data!.docs) {
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  int unreadCount = data['unread_messages'][currentUserId] ?? 0;
                  totalUnread += unreadCount;
                }

                return Dismissible(
                  key: Key(chatRoomDoc.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    final bool? result = await showDialog<bool>(
                      context: context,
                      barrierDismissible:
                          false, // Prevent dismissing by tapping outside
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: bc,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text("Confirmation"),
                          content: const Text(
                            "Are you sure you want to delete this chat?",
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(
                                  context,
                                ).pop(false); // Cancel action
                              },
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                await deleteChatRoom(
                                  currentUserId,
                                  otherUserId,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Chat deleted')),
                                );
                                Navigator.of(
                                  context,
                                ).pop(true); // Confirm delete
                              },
                              child: const Text(
                                "OK",
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                    return result ??
                        false; // Return true or false based on user action
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 20.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    margin: const EdgeInsets.only(bottom: 10),
                    width: MediaQuery.of(context).size.width * 0.92,
                    height: MediaQuery.of(context).size.height * 0.1,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        username,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                      ),
                      subtitle: Text(
                        lastMessage,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                      ),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            userData["profilepic"] != null
                                ? NetworkImage(userData["profilepic"])
                                : null,
                        child:
                            userData["profilepic"] == null
                                ? const Icon(Icons.person, size: 25)
                                : null,
                      ),
                      trailing:
                          chatRoomDoc['unread_messages'][currentUserId] != 0
                              ? CircleAvatar(
                                radius: 15,
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  11,
                                  220,
                                  147,
                                ),
                                child: Text(
                                  totalUnread.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                              : Icon(
                                Icons.check,
                                color:
                                    chatRoomDoc["isRead"] == true
                                        ? Colors.blue
                                        : Colors.grey,
                              ),
                      onTap: () async {
                        await resetUnreadMessages(currentUserId, otherUserId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ChatPage(
                                  // receiverEmail: userData["userEmail"],
                                  receiverId: otherUserId,
                                  username: username,
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection("users").doc(userId).get();
    return userDoc.data() as Map<String, dynamic>?;
  }

  Future<void> deleteChatRoom(String userId, String otherUserId) async {
    // Create chatroom ID
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatroomId = ids.join("_");

    try {
      // Get all messages in the chatroom
      QuerySnapshot messagesSnapshot =
          await FirebaseFirestore.instance
              .collection("chat_rooms")
              .doc(chatroomId)
              .collection("messages")
              .get();

      // Delete each message document
      for (QueryDocumentSnapshot message in messagesSnapshot.docs) {
        await message.reference.delete();
      }

      // Delete the chatroom document itself
      await FirebaseFirestore.instance
          .collection("chat_rooms")
          .doc(chatroomId)
          .delete();
    } catch (e) {
      print("Error deleting chat room: $e");
    }
  }

  Future<void> resetUnreadMessages(
    String currentuserUid,
    String otherUserId,
  ) async {
    List<String> ids = [currentuserUid, otherUserId];
    ids.sort();
    String chatroomId = ids.join("_");

    await _firestore.collection("chat_rooms").doc(chatroomId).update({
      'isRead': true,
      'unread_messages': {
        currentuserUid: 0, // Reset for the sender
        otherUserId: 0,
      }, // Use merge to update the field without overwriting the entire document
    });
  }
}
