import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petpalace/authentication/authState/authState.dart';
import 'package:petpalace/authentication/events/authEvent.dart';

class Authbloc extends Bloc<Authevent, Authstate> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Authbloc() : super(AuthInitial()) {
    on<SignInRequested>(_signIn);
    on<SignupIsRequested>(_signUp);
    on<LogoutIsRequested>(_logOut);
  }
  void _signIn(SignInRequested event, Emitter<Authstate> emit) async {
    emit(AuthLoading());
    try {
      await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(Authenticated());
      print('Login successful: ${event.email}');
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.code));
    }
  }

  void _saveTokenToDatabase(String? token) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && token != null) {
      final userRef = FirebaseFirestore.instance
          .collection('usertokens')
          .doc(user.uid);
      userRef.set({'token': token}, SetOptions(merge: true));
    }
  }

  Future<void> makeUserDocument(
    UserCredential? userCredential,
    String name,
    String password,
  ) async {
    if (userCredential != null && userCredential.user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
            "name": name,
            "userEmail": userCredential.user!.email,
            "password": password,
            "uid": userCredential.user!.uid,
          });
    }
  }

  void _signUp(SignupIsRequested event, Emitter<Authstate> emit) async {
    if (event.password != event.confirmpassword) {
      emit(const AuthError("Passwords do not match"));
      return;
    }

    emit(AuthLoading());
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: event.email,
            password: event.password,
          );

      // Creating user document in Firestore
      await makeUserDocument(userCredential, event.name, event.password);

      // Fetching FCM Token
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        _saveTokenToDatabase(token);
      }

      // Emitting success state
      emit(Authenticated());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_getErrorMessage(e.code)));
    } catch (e) {
      emit(const AuthError("An unexpected error occurred."));
    }
  }

  // Helper function to map Firebase errors to user-friendly messages
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'The password is too weak.';
      default:
        return 'An unknown error occurred.';
    }
  }

  void _logOut(LogoutIsRequested event, Emitter<Authstate> emit) async {
    emit(AuthLoading());
    try {
      await _auth.signOut();
      emit(UnAuthenticated());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.code));
    }
  }
}
