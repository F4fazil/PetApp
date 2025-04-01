import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Lottieloading extends StatelessWidget {
  const Lottieloading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Lottie.asset("assets/lottie/loading.json",
            height: 200, width: 200));
  }
}
