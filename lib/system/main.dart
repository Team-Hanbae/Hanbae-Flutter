import 'package:flutter/material.dart';
import 'package:hanbae/presentation/home/home_screen.dart';

void main() {
  runApp(Hanbae());
}

class Hanbae extends StatelessWidget {
  Hanbae({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}
