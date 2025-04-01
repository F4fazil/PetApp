import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:petpalace/Emergency_sos/Notification_handler.dart';
import 'package:petpalace/Emergency_sos/device_token.dart';

class SOSButton extends StatelessWidget {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final NotificationService _notificationService = NotificationService();
  final DeviceToken _deviceToken = DeviceToken();

  SOSButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: IconButton(
        onPressed: () async {
          // Show the loading dialog
          showLoadingDialog(context);

          // Send the notification
          try {
            await _notificationService.sendNotificationToAllUsers(
              "Emergency SOS",
              "A pet owner needs immediate assistance!",
            );

            // Update the dialog to show "Message Sent"
            Navigator.of(context).pop(); // Close the loading dialog
            showMessageSentDialog(context);
          } catch (e) {
            // Handle errors
            Navigator.of(context).pop(); // Close the loading dialog
            showErrorMessageDialog(context, e.toString());
          }
        },
        icon: const Icon(Icons.error, color: Colors.red, size: 30),
      ),
    );
  }

  // Show a loading dialog
  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing manually
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.pets, color: Colors.orange),
              SizedBox(width: 25),
              Text("Sending SOS...", style: TextStyle(fontSize: 15)),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.orange),
              SizedBox(height: 15),
              Text(
                "Please wait while we send your emergency alert.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      },
    );
  }

  // Show a "Message Sent" dialog
  void showMessageSentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 25),
              Text("Message Sent", style: TextStyle(fontSize: 15)),
            ],
          ),
          content: const Text(
            "Your emergency alert has been sent successfully.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Show an error message dialog
  void showErrorMessageDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 25),
              Text("Error", style: TextStyle(fontSize: 15)),
            ],
          ),
          content: Text(
            "Failed to send the emergency alert: $errorMessage",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
