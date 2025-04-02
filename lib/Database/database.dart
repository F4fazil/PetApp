// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DataBaseStorage {
  //adding item to Firebase
  User? user = FirebaseAuth.instance.currentUser;

  Future<void> addNotification(Map<String, dynamic> profileData) async {
    try {
      await FirebaseFirestore.instance
          .collection("notifications")
          .doc(user?.uid)
          .collection("posts")
          .doc("notifications")
          .collection("_")
          .add(profileData);
      print(user.toString());
      print("Data added to Firestore successfully! ");
    } catch (e) {
      print('Error adding data to Firestore: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getNotificationList() async* {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }

    String currentUserEmail = user.uid;

    var userSnapshot =
        await FirebaseFirestore.instance.collection("notifications").get();
    var filteredUsers = userSnapshot.docs.where(
      (doc) => doc.id != currentUserEmail,
    );

    List<Map<String, dynamic>> combinedData = [];

    for (var userDoc in filteredUsers) {
      var propertySnapshot =
          await userDoc.reference
              .collection("posts")
              .doc("notifications")
              .collection("_")
              .get();

      for (var propertyDoc in propertySnapshot.docs) {
        combinedData.add(propertyDoc.data());
      }
    }

    yield combinedData;
  }

  Future<void> add_data_to_Cat(Map<String, dynamic> profileData) async {
    profileData['postId'] = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      // ignore: avoid_single_cascade_in_expression_statements
      FirebaseFirestore.instance
          .collection("users")
          .doc(user?.uid)
          .collection("petDetails")
          .doc("Cat")
        ..collection("_").doc(profileData['postId']).set(profileData);

      print("Data added to Firestore successfully! ");
    } catch (e) {}
  }

  Future<void> add_data_to_Dog(Map<String, dynamic> profileData) async {
    profileData['postId'] = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      FirebaseFirestore.instance
          .collection("users")
          .doc(user?.uid)
          .collection("petDetails")
          .doc("Dog")
        ..collection("_").doc(profileData['postId']).set(profileData);
      print(user.toString());
      print("Data added to Firestore successfully! ");
    } catch (e) {
      print('Error adding data to Firestore: $e');
    }
  }

  Future<void> add_data_to_PetSitter(Map<String, dynamic> profileData) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user?.uid)
          .collection("petSitter")
          .add(profileData);
      print(profileData);
      print("Data added to Firestore successfully! ");
    } catch (e) {
      print('Error adding data to Firestore: $e');
    }
  }

  Future<void> add_data_to_Vet(Map<String, dynamic> profileData) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user?.uid)
          .collection("vet")
          .add(profileData);
      print(user.toString());
      print("Data added to Firestore successfully! ");
    } catch (e) {
      print('Error adding data to Firestore: $e');
    }
  }

  Future<void> add_data_to_SameBreed(Map<String, dynamic> profileData) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user?.uid)
          .collection("SameBreed")
          .add(profileData);
      print(user.toString());
      print("Data added to Firestore successfully! ");
    } catch (e) {
      print('Error adding data to Firestore: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> retrieveDataFromSameBreed() async* {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }

    String currentUserEmail = user.uid;

    // Fetch all users except the current user
    var userSnapshot =
        await FirebaseFirestore.instance.collection("users").get();
    var filteredUsers = userSnapshot.docs.where(
      (doc) => doc.id != currentUserEmail,
    );

    List<Map<String, dynamic>> combinedData = [];

    // For each filtered user, fetch their home property details
    for (var userDoc in filteredUsers) {
      var propertySnapshot =
          await userDoc.reference.collection("SameBreed").get();

      for (var propertyDoc in propertySnapshot.docs) {
        combinedData.add(propertyDoc.data());
      }
    }

    yield combinedData;
  }

  //fav
  Future<List<Map<String, dynamic>>> getFav() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user?.uid)
              .collection("propertyDetails")
              .doc("favourite")
              .collection("_")
              .get();

      List<Map<String, dynamic>> dataList = [];

      if (querySnapshot.docs.isNotEmpty) {
        for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
          Map<String, dynamic> data =
              documentSnapshot.data() as Map<String, dynamic>;
          dataList.add(data);
        }

        return dataList;
      } else {
        print('No documents found in the collection');
        return [];
      }
    } catch (e) {
      print('Error retrieving data from Firestore: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> retrieveDataFromCat() async* {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }

    String currentUserEmail = user.uid;

    var userSnapshot =
        await FirebaseFirestore.instance.collection("users").get();
    var filteredUsers = userSnapshot.docs.where(
      (doc) => doc.id != currentUserEmail,
    );

    List<Map<String, dynamic>> combinedData = [];

    for (var userDoc in filteredUsers) {
      var propertySnapshot =
          await userDoc.reference
              .collection("petDetails")
              .doc("Cat")
              .collection("_")
              .get();

      for (var propertyDoc in propertySnapshot.docs) {
        combinedData.add(propertyDoc.data());
      }
    }

    yield combinedData;
  }

  Stream<List<Map<String, dynamic>>> retrieveDataFroDog() async* {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }

    String currentUserEmail = user.uid;

    // Fetch all users except the current user
    var userSnapshot =
        await FirebaseFirestore.instance.collection("users").get();
    var filteredUsers = userSnapshot.docs.where(
      (doc) => doc.id != currentUserEmail,
    );

    List<Map<String, dynamic>> combinedData = [];

    // For each filtered user, fetch their home property details
    for (var userDoc in filteredUsers) {
      var propertySnapshot =
          await userDoc.reference
              .collection("petDetails")
              .doc("Dog")
              .collection("_")
              .get();

      for (var propertyDoc in propertySnapshot.docs) {
        combinedData.add(propertyDoc.data());
      }
    }

    yield combinedData;
  }

  Stream<List<Map<String, dynamic>>> retrieveDataFroPetSitter() async* {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }

    String currentUserEmail = user.uid;

    // Fetch all users except the current user
    var userSnapshot =
        await FirebaseFirestore.instance.collection("users").get();
    var filteredUsers = userSnapshot.docs.where(
      (doc) => doc.id != currentUserEmail,
    );

    List<Map<String, dynamic>> combinedData = [];

    // For each filtered user, fetch their home property details
    for (var userDoc in filteredUsers) {
      var propertySnapshot =
          await userDoc.reference.collection("petSitter").get();

      for (var propertyDoc in propertySnapshot.docs) {
        combinedData.add(propertyDoc.data());
      }
    }

    yield combinedData;
  }

  Stream<List<Map<String, dynamic>>> retrieveDataFromVet() async* {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }

    String currentUserEmail = user.uid;

    // Fetch all users except the current user
    var userSnapshot =
        await FirebaseFirestore.instance.collection("users").get();
    var filteredUsers = userSnapshot.docs.where(
      (doc) => doc.id != currentUserEmail,
    );

    List<Map<String, dynamic>> combinedData = [];

    // For each filtered user, fetch their home property details
    for (var userDoc in filteredUsers) {
      var propertySnapshot = await userDoc.reference.collection("vet").get();

      for (var propertyDoc in propertySnapshot.docs) {
        combinedData.add(propertyDoc.data());
      }
    }

    yield combinedData;
  }

  // Helper function to merge streams
  Stream<List<Map<String, dynamic>>> combineStreams(
    List<Stream<List<Map<String, dynamic>>>> streams,
  ) {
    return StreamZip(streams).map((listOfLists) {
      List<Map<String, dynamic>> combinedData = [];
      for (var list in listOfLists) {
        combinedData.addAll(list);
      }
      return combinedData;
    });
  }

  Stream<List<Map<String, dynamic>>> CurrentUserDataFromCat() async* {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }

    String currentUserEmail = user.uid;

    var userSnapshot =
        await FirebaseFirestore.instance.collection("users").get();
    var filteredUsers = userSnapshot.docs.where(
      (doc) => doc.id == currentUserEmail,
    );

    List<Map<String, dynamic>> combinedData = [];

    for (var userDoc in filteredUsers) {
      var propertySnapshot =
          await userDoc.reference
              .collection("petDetails")
              .doc("Cat")
              .collection("_")
              .get();

      for (var propertyDoc in propertySnapshot.docs) {
        combinedData.add(propertyDoc.data());
      }
    }

    yield combinedData;
  }

  Stream<List<Map<String, dynamic>>> currentUserDataFromDog() async* {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }

    String currentUserUid = user.uid;

    // Fetch the dog's details for the current user
    var dogSnapshot =
        await FirebaseFirestore.instance
            .collection("users")
            .doc(currentUserUid)
            .collection("petDetails")
            .doc("Dog")
            .collection("_")
            .get();

    List<Map<String, dynamic>> combinedData = [];

    // Add the documents to the list
    for (var propertyDoc in dogSnapshot.docs) {
      combinedData.add(propertyDoc.data());
    }

    yield combinedData; // Yield the data for the current user's dogs
  }

  Stream<List<Map<String, dynamic>>> MyPost() {
    // Define the list of streams
    List<Stream<List<Map<String, dynamic>>>> streams = [
      CurrentUserDataFromCat(),
      currentUserDataFromDog(),
    ];

    // Combine the streams into a single stream
    return combineStreams(streams);
  }

  // Function to get all property data
  Stream<List<Map<String, dynamic>>> retrieveAllData() {
    // Define the list of streams
    List<Stream<List<Map<String, dynamic>>>> streams = [
      retrieveDataFromCat(),
      retrieveDataFroDog(),
    ];

    // Combine the streams into a single stream
    return combineStreams(streams);
  }

  Future<void> scheduleMeeting(
    String userUid,
    String vetUid,
    String vetName,
    String userName,
    DateTime meetingDate,
    TimeOfDay meetingTime,
  ) async {
    List<String> meetingId = [userUid, vetUid];
    meetingId.sort();
    String meetingRoomId = meetingId.join("_");

    // Combine date and time into a single DateTime object for storage
    DateTime meetingDateTime = DateTime(
      meetingDate.year,
      meetingDate.month,
      meetingDate.day,
      meetingTime.hour,
      meetingTime.minute,
    );

    await FirebaseFirestore.instance
        .collection('meetings')
        .doc(meetingRoomId)
        .set({
          "vetName": vetName,
          "vetUid": vetUid,
          "userName": userName,
          "userUid": userUid,
          "meetingDateTime": meetingDateTime,
          "status":
              "pending", // The vet can update this to "accepted" or "declined"
        });
  }

  Future<List<Map<String, dynamic>>> fetchUserMeetings() async {
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    QuerySnapshot snapshot =
        await FirebaseFirestore.instance
            .collection('meetings')
            .where('userUid', isEqualTo: currentUserUid)
            .get();

    List<Map<String, dynamic>> meetings =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    return meetings;
  }

  Future<List<Map<String, dynamic>>> fetchVetMeetings() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }

    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    try {
      QuerySnapshot meetingsSnapshot =
          await FirebaseFirestore.instance
              .collection('meetings')
              .where('vetUid', isEqualTo: currentUserUid)
              .get();

      List<Map<String, dynamic>> meetings = [];
      for (var doc in meetingsSnapshot.docs) {
        meetings.add(doc.data() as Map<String, dynamic>);
      }

      return meetings;
    } catch (e) {
      print("Error fetching vet meetings: $e");
      return [];
    }
  }

  Future<void> addData_interest(List<String> profileData) async {
    try {
      await FirebaseFirestore.instance
          .collection("usersProfile")
          .doc("interest")
          .update({'interests': profileData});

      print('Data added to Firestore successfully!');
    } catch (e) {
      print('Error adding data to Firestore: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsersData() async {
    try {
      // Fetch all users except the current user
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection("users").get();

      // Filter out the current user's data
      List<Map<String, dynamic>> allUsersData =
          querySnapshot.docs
              .where(
                (doc) => doc.id != user?.email,
              ) // Assuming email is used as a unique identifier
              .map((doc) => doc.data())
              .toList();

      return allUsersData;
    } catch (e) {
      print('Error retrieving data from Firestore: $e');
      return [];
    }
  }

  void deleteFav(Map<String, dynamic> temp) {
    try {
      String documentId = temp['documentId']; // Change this to your actual key
      FirebaseFirestore.instance
          .collection("users")
          .doc(user?.email)
          .collection("profileData")
          .doc()
          .delete();
      print("Data removed from Firestore successfully! ");
    } catch (e) {
      print('Error removing data from Firestore: $e');
    }
  }

  void signout() {
    FirebaseAuth.instance.signOut();
  }
}

  //fetching data from name_or_age of currentuser

  

