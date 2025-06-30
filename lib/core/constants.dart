import 'package:flutter/material.dart';

// رنگ‌ها، فونت‌ها، اندازه‌ها و سایر ثابت‌ها

class AppColors {
  static const primary = Color(0xFF00BFAE); // teal
  static const accent = Color(0xFFFFC107); // yellow
  static const background = Color(0xFFF1F8E9); // light green
  static const button = Color(0xFF00C853); // green accent
  static const buttonText = Colors.white;
  static const appBar = Color(0xFF00B8D4); // cyan
}

class AppGradients {
  static const main = LinearGradient(
    colors: [Color(0xFF00BFAE), Color(0xFF00C853), Color(0xFFFFC107)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTextStyles {
  static const title = TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
  static const body = TextStyle(fontSize: 16);
}

class AppSizes {
  static const double padding = 16.0;
  static const double borderRadius = 12.0;
}
