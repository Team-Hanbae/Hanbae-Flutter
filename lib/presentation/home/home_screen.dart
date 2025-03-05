import 'package:flutter/material.dart';
import 'package:hanbae/data/sound_manager.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final _soundManager = SoundManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ElevatedButton(
        onPressed: (){
          _soundManager.play("sounds/beep_medium.wav");
        },
        child: Text("Beep Button")),
    );
  }
}