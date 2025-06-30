import 'package:flutter/material.dart';
import '../core/enums.dart';
import '../core/constants.dart';
import '../screens/input_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('شبیه‌ساز زمان‌بندی سیستم‌عامل'),
        backgroundColor: AppColors.appBar,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppGradients.main),
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: 260,
              height: 80,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.button,
                  foregroundColor: AppColors.buttonText,
                  textStyle: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 8,
                ),
                child: const Text('شروع'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InputScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
