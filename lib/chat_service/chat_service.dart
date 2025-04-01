import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petpalace/Emergency_sos/Notification_handler.dart';
import 'message.dart'; // Ensure this is correctly imported

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timestamp timestamp = Timestamp.now();
  bool isRead = false;

  // Send message function
  Future<void> sendmessage(String receiverid, String message) async {
    try {
      final currentuserid = _firebaseAuth.currentUser!.uid;
      final currentusergmail = _firebaseAuth.currentUser!.email.toString();

      final currentUserRef = _firestore.collection('users').doc(currentuserid);
      final currentUserDoc = await currentUserRef.get();

      // Check if the document exists and fetch the 'name' field
      if (currentUserDoc.exists) {
        final currentUserName = currentUserDoc['name'];

        Message newMessage = Message(
          receiverid,
          currentusergmail,
          currentuserid,
          message,
          timestamp,
        );

        // Create chatroom ID using UIDs
        List<String> ids = [currentuserid, receiverid];
        ids.sort();
        String chatroomId = ids.join("_");

        // Store the message in Firestore using the user's UID
        await _firestore.collection("chat_rooms").doc(chatroomId).set({
          'name': currentUserName,
          'userEmail': currentusergmail,
          'participants': [currentuserid, receiverid],
          'last_message': message,
          'timestamp': timestamp,
          'isRead': false,
          'unread_messages': {
            currentuserid: 0, // Reset for the sender
            receiverid: FieldValue.increment(1), // Increment for the receiver
          },
        }, SetOptions(merge: true));

        // Store the message inside the chatroom
        await _firestore
            .collection("chat_rooms")
            .doc(chatroomId)
            .collection("messages")
            .add(newMessage.toMap());

        // Send notification
        await NotificationService().sendMessageNotification(
          currentUserName,
          message,
          receiverid,
        );
      } else {
        print("User document does not exist.");
      }
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  // Get messages stream function
  Stream<QuerySnapshot> getMessage(String userid, String otheruserID) {
    // Create chatroom ID using UIDs
    List<String> ids = [userid, otheruserID];
    ids.sort();
    String chatroomId = ids.join("_");

    // Get messages from the chatroom using the current user's UID
    return _firestore
        .collection("chat_rooms")
        .doc(chatroomId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}
