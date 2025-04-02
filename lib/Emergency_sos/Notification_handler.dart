import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  final String _fcmUrl =
      'https://fcm.googleapis.com/v1/projects/propertypall/messages:send';

  // Notification  For all users except current
  Future<void> sendNotificationToAllUsers(String title, String body) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final currentUserRef = FirebaseFirestore.instance
        .collection('usertokens')
        .doc(currentUser.uid);
    final currentUserDoc = await currentUserRef.get();
    final currentUserToken = currentUserDoc['token'];
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('usertokens').get();
    for (var doc in snapshot.docs) {
      final token = doc['token'];
      if (token != currentUserToken) {
        await sendNotification(title, body, token);
      }
    }
  }

  // Msg For specific person
  Future<void> sendMessageNotification(
    String title,
    String body,
    String recipientUid,
  ) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Fetch the recipient's token using their UID
    final recipientRef = FirebaseFirestore.instance
        .collection('usertokens')
        .doc(recipientUid);
    final recipientDoc = await recipientRef.get();

    if (recipientDoc.exists) {
      final recipientToken = recipientDoc['token'];

      // Check if the recipient token is not the same as the current user's token
      if (recipientToken != null) {
        await sendNotification(title, body, recipientToken);
      }
    }
  }

  // server_key_fetching_function
  Future<String> getAuthToken() async {
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];
    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson({
        "type": "service_account",
        "project_id": "propertypall",
        "private_key_id": "35cb5fca8828e0dc75b31ddf642cc6d94f2ebc07",
        "private_key":
            "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCihZe4afKS09zy\nCrh381BG0WawqP4QJMjR2bCoq2qKOhCWP5YUrlCsGkuvzPtaQ7e4vwGZdNlejaQs\nQl4ijXJU4XdOeZro0mOxDcuS5PAu9Ukg1uaX1X3zQ1nqg/n50P3uXK42IoOmd52M\npZ3y2I6px2DneXJYqbCpaOfMmOJrsvwCyO16iCdWt5hbxdEAFDp7e87VR0nJTA9J\nxugIQ7ogukBZib20iH5MyWUxjykH45pjlNFExYL6RmNTayEMhBtILhfGuFRiCtL8\nm8vajsp3rPiskCzLxA6g8lQo7iCrU9EOva/SpqTa+WOvQlCL0H2FlGSzu4M7Vu9a\nj2Y21EhXAgMBAAECggEALZE1W+BgwegjD74PwJn4zRJTL38CVPZrU+MsU+5T3dOv\n6OCFLOE+/zIUPINFiiZocaUkRqlrdMZT3JDzIc702nWo5NjVpSewCelrRZFpAlGF\nom5+kt2qBbXBlS5RvUhqmhVkRwtgTCFHjDK3WWp8fX/IXL5BYDibrrQaIdRPz5Aa\nCp7FqQ6iO5O8JU3Ud9uPEvgCmbEwW2IiRVXKlpfAWlGz5O2k3qveQoy85Ada31Ap\nlf5+Bn+52oa2jGTU6a/fNlHw28KMGxqA96tguZ73KBPOIrZK5SSB2h7cjTrFxzWS\nijDoqTljEJUcBlh6evvI+UoZcxyIdsqrvpxYrPJZIQKBgQDGmJOV6DJCjOhEF6pW\n1ww6/v1yx29cIgH/QQ45emycgbCSeX0XDaurIOq/t2c87Atq2p+Jqq0oXeYVJfFJ\n3WHQ9OhJ7xA48ejf0BmIVqpAcjLcRImUKeYHZ1l5ntandA9trVuE6FRt1uN/YJbY\nzXHxwyExkC9eK4ITTywrqB//JwKBgQDRf6b7NHxT9mgVSwEGBxezRWQ3HFJcoKov\nIzur3B6Lsl/mtXc/UGBmPtE1t9fibkBphIbTpXBw3uEpQaTmZ4+6NdUQZkzsnhXw\nhj1oC3ul/wbrHytlYmpddIT2oACOJ+jC2He8hDobyxZe+NPxSy0S9+Rb331wQxlp\nS/0ou/8rUQKBgGrL5BnqSxTkx4bOnyih7o7PTyZpP2ZxV1eX+XlJb5zeVUD/mhhK\nnrWhNvwwOZFWcnFc7gxPP10E2dUnmVEafx6qhTw1Fik5Vfz94K0jxdxwTQ+Mv9tw\niKYUmtY/Z7mXPTDC2ANqGPUUaTS3kYc3O/5B69jGa+KdTQ7rNZqoh8RjAoGBALiV\nf3uP+AdGcNhp+GHmN+SVPEIuawb/7FKR+Y5n6GXvaP3uXz3ixLzxlgV9kPIJcClI\nQj8SYiqgxcRC+VakYoePzMWhTR+h/fSpYktc6roMJH1fPi4a81qaQljGCxc1ZKjg\nb0cjPculOXW+SYctVG6FCahFFtGl3SrgcBLG6YGxAoGAIY5NfT4E3PBq0gM7ODQr\njsG57t7dnLgugnIA/2k0r9Q51N/VXwytuwp+hKEkgihdqWQ66rPxfJqaQd6F2hsv\nrxFhappdHk8J+nndn0SgRIlhZaY5GDKjyTNY/xlgjYy+xs/PzzFnyEmOESGlaPv6\nyNQvcf8yg6VXWHWdJp37G0c=\n-----END PRIVATE KEY-----\n",
        "client_email":
            "firebase-adminsdk-zg1es@propertypall.iam.gserviceaccount.com",
        "client_id": "109988975729385230394",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url":
            "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url":
            "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-zg1es%40propertypall.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com",
      }),
      scopes,
    );
    final accessserverkey = client.credentials.accessToken.data;
    return accessserverkey;
  }

  Future<void> sendNotification(String title, String body, String token) async {
    try {
      // Get the OAuth2 token
      final String authToken = await getAuthToken();
      if (authToken.isEmpty) {
        print("Failed to get auth token.");
        return;
      }

      final response = await http.post(
        Uri.parse(_fcmUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken', // Use the OAuth2 token here
        },
        body: jsonEncode(<String, dynamic>{
          'message': <String, dynamic>{
            'token': token,
            'notification': <String, dynamic>{'title': title, 'body': body},
            'android': <String, dynamic>{
              'priority': 'high',
              'notification': <String, dynamic>{'icon': 'ic_launcher'},
            },
          },
        }),
      );

      if (response.statusCode == 200) {
        print("sent successfully");
      } else {
        print('Failed to send notification. Response: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}
