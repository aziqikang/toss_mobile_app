// lib/src/styles/styles.dart

import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Colors.blueGrey;
  static const Color accent = Colors.red;
  static const Color background = Colors.black;
  static const Color buttonText = Colors.white;
  // Add more colors as needed
}

class AppTextStyles {
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.buttonText,
  );

  // Add more text styles as needed
}

class AppButtonStyles {
  static ButtonStyle redButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.accent, // Red background
    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
    textStyle: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
  );

  // Add more button styles as needed
}
