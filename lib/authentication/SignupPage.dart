import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petpalace/screens/feature_screens/homeScreen.dart';

import '../constant/constant.dart';
import '../screens/homepage.dart';
import '../widgets/login_signup_btn.dart';
import '../widgets/lottieLoading.dart';
import '../widgets/textfield.dart';
import 'LoginScreen.dart';
import 'authBloc/authBloc.dart';
import 'authState/authState.dart';
import 'events/authEvent.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  void _saveTokenToDatabase(String? token) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && token != null) {
      final userRef = FirebaseFirestore.instance
          .collection('usertokens')
          .doc(user.uid);
      userRef.set({'token': token}, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    Color btnColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          child: Column(
            children: [
              // Header Image
              Container(
                height: MediaQuery.of(context).size.height * 0.33,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(100),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Image.asset(
                  fit: BoxFit.fitHeight,
                  "assets/splash.png",
                  color: Theme.of(context).colorScheme.primary,
                  colorBlendMode: BlendMode.color,
                ),
              ),
              // Form Section
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: Stack(
                    children: [
                      // Form Fields
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            "Signup",
                            style: GoogleFonts.quicksand(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                              top: 20,
                            ),
                            child: MyTextField(
                              controller: nameTextController,
                              icon: Icon(Icons.person, color: btnColor),
                              hintText: 'Name',
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                              top: 20,
                            ),
                            child: MyTextField(
                              controller: emailTextController,
                              icon: Icon(Icons.mail_sharp, color: btnColor),
                              hintText: 'Email',
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                              top: 20,
                            ),
                            child: MyTextField(
                              obscureText: true,
                              controller: passwordTextController,
                              icon: Icon(Icons.password, color: btnColor),
                              hintText: 'Password',
                            ),
                          ),

                          const SizedBox(height: 50),
                        ],
                      ),
                      // Button and Text at the Bottom
                      Positioned(
                        bottom: 40, // 40px from the bottom
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            // Signup Button
                            BlocConsumer<Authbloc, Authstate>(
                              listener: (context, state) {
                                if (state is Authenticated) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MainScreen(),
                                    ),
                                  );
                                } else if (state is AuthError) {
                                  Future.delayed(
                                    const Duration(seconds: 0),
                                    () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(state.error)),
                                      );
                                    },
                                  );
                                }
                              },
                              builder: (context, state) {
                                if (state is AuthLoading) {
                                  return const Lottieloading();
                                }
                                return MyButton(
                                  onPressed: () {
                                    context.read<Authbloc>().add(
                                      SignupIsRequested(
                                        nameTextController.text,
                                        emailTextController.text,
                                        passwordTextController.text,
                                      ),
                                    );
                                  },
                                  text: 'Sign Up',
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            // "Already have an account?" Text
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Already have an account?',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.teal.shade300,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
