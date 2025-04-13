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

    // 화면 반짝임 기능
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
          onPressed: () {
            Navigator.pop(
              context,
            ); // This will pop the current screen off the navigation stack
          },
          icon: Icon(Icons.chevron_left),
        ),
        title: Text(
          jangdan.name,
          style: AppTextStyles.bodyR.copyWith(color: AppColors.textSecondary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.read<MetronomeBloc>().add(const ResetMetronome());
            },
            icon: Icon(Icons.replay),
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

          // 화면반짝임 기능 컬러박스
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