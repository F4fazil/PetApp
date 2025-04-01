import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../Database/database.dart';
import '../../widgets/lottieLoading.dart';

class VetMeetingsScreen extends StatelessWidget {
  const VetMeetingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text('Vet Meetings'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: DataBaseStorage().fetchVetMeetings(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Lottieloading();
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No meetings available.'));
            }

            final meetings = snapshot.data!;

            return ListView.builder(
              itemCount: meetings.length,
              itemBuilder: (context, index) {
                final meeting = meetings[index];
                final meetingDateTime =
                    (meeting['meetingDateTime'] as Timestamp).toDate();
                List<String> meetingId = [
                  meeting["userUid"],
                  meeting["vetUid"]
                ];
                meetingId.sort();
                String meetingRoomId = meetingId.join("_");

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meeting with ${meeting['userName']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Date: ${meetingDateTime.toLocal().toString().split(' ')[0]}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Time: ${meetingDateTime.hour}:${meetingDateTime.minute}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                meeting['status'],
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: meeting['status'] == 'pending'
                                  ? Colors.orange
                                  : meeting['status'] == 'accepted'
                                      ? Colors.green
                                      : Colors.red,
                            ),
                            const Spacer(),
                            if (meeting['status'] == 'pending')
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check,
                                        color: Colors.green),
                                    onPressed: () => _updateMeetingStatus(
                                        meetingRoomId, 'accepted'),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.red),
                                    onPressed: () => _updateMeetingStatus(
                                        meetingRoomId, 'declined'),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Function to update meeting status
  Future<void> _updateMeetingStatus(String meetingId, String status) async {
    try {
      print("Updating meeting with ID: $meetingId to status: $status");
      await FirebaseFirestore.instance
          .collection('meetings')
          .doc(meetingId)
          .update({'status': status});

      print("Meeting status updated to $status");
    } catch (e) {
      print("Error updating meeting status: $e");
    }
  }
}
