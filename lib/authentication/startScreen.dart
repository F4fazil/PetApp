import 'package:flutter/material.dart';
import 'package:petpalace/authentication/LoginScreen.dart';
import 'package:petpalace/constant/constant.dart';
import 'package:petpalace/widgets/login_signup_btn.dart';

import 'SignupPage.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.85,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              image: const DecorationImage(
                fit: BoxFit.fitWidth,
                image: AssetImage("assets/splash.jpg"),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 50),
                Text("Adopt a pet,", style: splashScreentext),
                Text("Save Their  Life,", style: splashScreentext),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height * 0.15,
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: MyButton(
                    text: ("Login"),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: MyButton(
                    text: ("Sign Up"),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
