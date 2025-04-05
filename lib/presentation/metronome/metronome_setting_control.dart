import 'package:flutter/material.dart';

class MetronomeSettingControl extends StatelessWidget {
  const MetronomeSettingControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(Icons.splitscreen, size: 32),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.offline_bolt_outlined, size: 32),
          onPressed: () {},
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.music_note, size: 28),
          itemBuilder:
              (context) => const [
                PopupMenuItem(value: 'Beep', child: Text('Beep')),
                PopupMenuItem(value: 'Click', child: Text('Click')),
                PopupMenuItem(value: 'Woodblock', child: Text('Woodblock')),
              ],
          onSelected: (value) {},
        ),
      ],
    );
  }
}
