import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:petpalace/call_services/video_call.dart';
import 'package:petpalace/constant/constant.dart';
import 'package:petpalace/widgets/lottieLoading.dart';
import 'chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiverId;
  final String username;

  const ChatPage({super.key, required this.receiverId, required this.username});

  @override
  // ignore: library_private_types_in_public_api
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final TextEditingController _textEditingController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  void sendMsg() async {
    if (_textEditingController.text.isEmpty) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Message is empty'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (_textEditingController.text.isNotEmpty) {
      await _chatService.sendmessage(
        widget.receiverId,
        _textEditingController.text,
      );
      _textEditingController.clear();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bc,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "🙎🏻‍♂️${widget.username}",
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: app_bc,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => const CallPage()));
            },
            icon: const Icon(Icons.video_call, size: 35, color: Colors.black),
          ),
        ],
      ),
      body: Column(
        children: [Expanded(child: _buildMessageList()), _buildInputMessage()],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessage(
        _firebaseAuth.currentUser!.uid,
        widget.receiverId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Lottieloading();
        }
        if (snapshot.hasData) {
          var messageDocs = snapshot.data!.docs;
          if (messageDocs.isEmpty) {
            return const Center(child: Text('No messages yet.'));
          }
          return ListView.builder(
            itemCount: messageDocs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = messageDocs[index];

              return _buildMessageItem(doc);
            },
          );
        }
        return Container();
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
    Timestamp timestamp = data['timestamp'];
    DateTime dateTime = timestamp.toDate();
    String formattedTime = DateFormat('h:mm a').format(dateTime);
    bool isRight = (data["senderid"] == _firebaseAuth.currentUser!.uid);
    var alignment = isRight ? Alignment.centerRight : Alignment.centerLeft;
    var backgroundColor = isRight ? Colors.tealAccent : Colors.yellow;

    return Container(
      alignment: alignment,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment:
            isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(15),
              gradient:
                  isRight
                      ? LinearGradient(colors: [app_bc, app_bc])
                      : LinearGradient(
                        colors: [Colors.grey.shade300, Colors.grey.shade300],
                      ),
            ),
            child: Text(
              data["message"],
              style: TextStyle(
                color: isRight ? Colors.black : Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 8),
            child: Text(
              formattedTime,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                hintText: "Enter a message",
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.message, color: app_bc),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: app_bc, width: 0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: app_bc, width: 1.3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => sendMsg(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.teal,
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
