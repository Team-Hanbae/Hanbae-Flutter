import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/metronome/metronome_bloc.dart';
import 'package:hanbae/model/sound.dart';

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
        PopupMenuButton<Sound>(
          icon: Icon(Icons.music_note, size: 28),
          itemBuilder:
              (context) => const [
                PopupMenuItem(value: Sound.jangu, child: Text('장구')),
                PopupMenuItem(value: Sound.buk, child: Text('북')),
                PopupMenuItem(value: Sound.clave, child: Text('나무')),
              ],
          onSelected: (value) {
            context.read<MetronomeBloc>().add(ChangeSound(value));
          },
        ),
      ],
    );
  }
}
