import 'package:flutter/material.dart';

class OsmDailogue {
  final BuildContext context;

  OsmDailogue(this.context);

  void showSnackBar(String des) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating, // Makes the SnackBar float
        margin: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 5,
        ), // Adds margin
        backgroundColor:
            Theme.of(
              context,
            ).colorScheme.primary, // Customize the background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
        content: Text(
          des, // Display the description text
          style: const TextStyle(color: Colors.white), // Customize text style
        ),
      ),
    );
  }
}
