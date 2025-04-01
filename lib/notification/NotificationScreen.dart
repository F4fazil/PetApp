// ignore: file_names
import 'package:flutter/material.dart';
import 'package:petpalace/Database/database.dart';
import 'package:petpalace/screens/detailPage_screen.dart';
import 'package:petpalace/widgets/lottieLoading.dart';
import '../constant/constant.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final DataBaseStorage _dataBaseStorage = DataBaseStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bc,
      appBar: AppBar(
        backgroundColor: app_bc,
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _dataBaseStorage.getNotificationList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Lottieloading();
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.hasData) {
            var notifications = snapshot.data!;
            if (notifications.isEmpty) {
              return const Center(
                child: Text(
                  'No notifications found.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                var notification = notifications[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child:
                          notification['images'] != null &&
                                  notification['images'] is List &&
                                  notification['images'].isNotEmpty
                              ? Image.network(
                                notification['images'][0],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                              : const Icon(
                                Icons.notifications,
                                size: 50,
                                color: Colors.grey,
                              ),
                    ),
                    title: Text(
                      '${notification['name']} posted a new post',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      'Price: ${notification['price'] ?? 'No Message'}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        notification['pet_type'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    onTap: () {
                      // Navigate to post detail screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => DetailPage(homeData: notification),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }

          return const Center(
            child: Text(
              'No data available.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
