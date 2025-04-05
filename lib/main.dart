import 'package:flutter/material.dart';
import 'package:hanbae/presentation/home/home_screen.dart';
import 'package:hanbae/theme/colors.dart';

void main() {
  runApp(Hanbae());
}

class Hanbae extends StatelessWidget {
  const Hanbae({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        // ThemeData.dark()를 유지하면서
        scaffoldBackgroundColor:
            AppColors.backgroundDefault, // scaffold 배경색을 오버라이드
      ),
      home: HomeScreen(),
    );
  }
}
