import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/metronome/metronome_bloc.dart';

class MetronomeSettingControl extends StatelessWidget {
  const MetronomeSettingControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(Icons.splitscreen, size: 32),
          onPressed: () {
            context.read<MetronomeBloc>().add(ToggleSobak());
          },
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
