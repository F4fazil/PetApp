import 'package:firebase_messaging/firebase_messaging.dart';

class DeviceToken {


  Future<String?> getToken() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? token = await messaging.getToken();
  return token;
  // You can store this token in Firestore or your backend for later use.
}
}


