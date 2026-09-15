import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'core/app_colors.dart';

class GharKaKhanaApp extends StatelessWidget {
  const GharKaKhanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ghar Ka Khana',

      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,

        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
        ),

        fontFamily: 'Poppins',

        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
        ),
      ),

      home: const SplashScreen(),
    );
  }
}