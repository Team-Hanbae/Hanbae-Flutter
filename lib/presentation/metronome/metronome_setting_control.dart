import 'package:flutter/material.dart';

class MetronomeSettingControl extends StatelessWidget {
  const MetronomeSettingControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: IconButton(onPressed: () {}, icon: Icon(Icons.splitscreen))),
        Expanded(child: IconButton(onPressed: () {}, icon: Icon(Icons.offline_bolt_outlined))),
      ],
    );
  }
}