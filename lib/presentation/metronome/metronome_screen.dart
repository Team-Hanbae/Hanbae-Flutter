import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanbae/model/jangdan.dart';
import 'package:hanbae/presentation/metronome/hanbae_board.dart';
import 'package:hanbae/presentation/metronome/metronome_control.dart';
import 'package:hanbae/presentation/metronome/metronome_options.dart';
import 'package:hanbae/bloc/metronome/metronome_bloc.dart';
import 'package:hanbae/theme/colors.dart';
import 'package:hanbae/theme/text_styles.dart';

class MetronomeScreen extends StatefulWidget {
  const MetronomeScreen({super.key, required this.jangdan});
  final Jangdan jangdan;

  @override
  _MetronomeScreenState createState() => _MetronomeScreenState();
}

class _MetronomeScreenState extends State<MetronomeScreen> {
  bool _showFlashOverlay = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<MetronomeBloc, MetronomeState>(
      listener: (context, state) {
        if (state.isFlashOn &&
            state.isPlaying &&
            state.currentRowIndex == 0 &&
            state.currentDaebakIndex == 0 &&
            state.currentSobakIndex == 0) {
          setState(() => _showFlashOverlay = true);
          Future.delayed(const Duration(milliseconds: 100), () {
            setState(() => _showFlashOverlay = false);
          });
        }
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              toolbarHeight: 44.0,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.chevron_left),
              ),
              title: Text(
                widget.jangdan.name,
                style: AppTextStyles.bodyR.copyWith(color: AppColors.textSecondary),
              ),
              centerTitle: true,
              actions: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.replay)),
                PopupMenuButton(
                  icon: const Icon(Icons.upload),
                  itemBuilder: (c) => const [
                    PopupMenuItem(child: Text("popupMenu1")),
                    PopupMenuItem(child: Text("popupMenu2")),
                    PopupMenuItem(child: Text("popupMenu3")),
                  ],
                ),
              ],
            ),
            body: Column(
              children: [
                BlocBuilder<MetronomeBloc, MetronomeState>(
                  builder: (context, state) => HanbaeBoard(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: MetronomeOptions(),
                ),
                BlocBuilder<MetronomeBloc, MetronomeState>(
                  builder: (context, state) => MetronomeControl(),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !_showFlashOverlay,
              child: AnimatedOpacity(
                opacity: _showFlashOverlay ? 1.0 : 0.0,
                duration: _showFlashOverlay
                    ? Duration.zero
                    : const Duration(milliseconds: 300),
                curve: Curves.linear,
                child: Container(color: AppColors.blink),
              ),
            ),
          ),
        ],
      ),
    );
  }
}