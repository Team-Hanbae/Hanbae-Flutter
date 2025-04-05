import 'package:flutter/material.dart';
import 'package:hanbae/model/jangdan.dart';
import 'package:hanbae/presentation/metronome/hanbae_board.dart';
import 'package:hanbae/presentation/metronome/metronome_control.dart';
import 'package:hanbae/presentation/metronome/metronome_setting_control.dart';

class MetronomeScreen extends StatelessWidget {
  const MetronomeScreen({super.key, required this.jangdan});
  final Jangdan jangdan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 44.0,
        leading: IconButton(onPressed: () {}, icon: Icon(Icons.chevron_left)),
        title: Text(jangdan.name),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.replay)),
          PopupMenuButton(
            icon: Icon(Icons.upload),
            itemBuilder: (context) => <PopupMenuEntry>[
              PopupMenuItem(child: Text("popupMenu1")),
              PopupMenuItem(child: Text("popupMenu2")),
              PopupMenuItem(child: Text("popupMenu3")),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 36.0,
            ),
            child: HanbaeBoard(),
          ),
          MetronomeSettingControl(),
          MetronomeControl(),
        ],
      ),
    );
  }
}
