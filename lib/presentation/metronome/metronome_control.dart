import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:flutter/material.dart';
import 'package:hanbae/theme/colors.dart';
import 'package:hanbae/theme/text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import the flutter_bloc package
import 'package:hanbae/bloc/metronome/metronome_bloc.dart'; // Import the MetronomeBloc
import 'dart:async';

import 'package:hive/hive.dart'; // Import the async package for Timer

class MetronomeControl extends StatefulWidget {
  final double iconSize;
  const MetronomeControl({super.key, required this.iconSize});

  @override
  _MetronomeControlState createState() => _MetronomeControlState();
}

class _MetronomeControlState extends State<MetronomeControl> {
  Timer? _bpmChangeTimer;

  @override
  Widget build(BuildContext context) {
    final isTapping = context.select(
      (MetronomeBloc bloc) => bloc.state.isTapping,
    );

    return Container(
      margin: const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),

      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: context.read<MetronomeBloc>().state.minimum ? 0 : 32,
                child: Align(
                  alignment: Alignment.center,
                  child:
                      isTapping
                          ? Container(
                            decoration: BoxDecoration(
                              color: AppColors.backgroundDefault,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 16,
                            ),
                            child: Text(
                              "원하는 빠르기로 계속 탭해주세요",
                              style: AppTextStyles.bodySb.copyWith(
                                color: AppColors.textDefault,
                              ),
                            ),
                          )
                          : Text(
                            '빠르기(BPM)',
                            style: AppTextStyles.calloutR.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                ),
              ),
              // AnimatedSizeAndFade(
              //   sizeDuration: Duration(seconds: 1),
              //   fadeDuration: Duration(seconds: 2),
              //   child:
              //       context.read<MetronomeBloc>().state.minimum
              //           ? minimumWidget(isTapping, ValueKey('minimum'))
              //           : mainMetronomeControlWidget(
              //             isTapping,
              //             ValueKey('minimum'),
              //           ),
              // ),
              AnimatedCrossFade(
                duration: Duration(milliseconds: 300),
                firstChild: minimumWidget(isTapping),
                secondChild: mainMetronomeControlWidget(isTapping),
                crossFadeState:
                    context.read<MetronomeBloc>().state.minimum
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
              ),
              // mainMetronomeControlWidget(isTapping),
            ],
          ),
        ),
      ),
    );
  }

  /// minimum이 false일 때의 ui
  Widget mainMetronomeControlWidget(isTapping) {
    return Column(
      children: [
        // 플마버튼, BPM숫자 row
        GestureDetector(
          onHorizontalDragUpdate: (direction) {
            if (direction.delta.dx < 0) {
              final bpm = context.read<MetronomeBloc>().state.bpm;
              final gap = ((bpm - 1) ~/ 2 * 2) - bpm;
              context.read<MetronomeBloc>().add(ChangeBpm(gap));
            } else if (direction.delta.dx > 0) {
              final bpm = context.read<MetronomeBloc>().state.bpm;
              final gap = ((bpm + 2) ~/ 2 * 2) - bpm;
              context.read<MetronomeBloc>().add(ChangeBpm(gap));
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Minus Button
              GestureDetector(
                onLongPressStart: (_) {
                  _bpmChangeTimer = Timer.periodic(
                    const Duration(milliseconds: 100),
                    (_) {
                      final bpm = context.read<MetronomeBloc>().state.bpm;
                      final gap = ((bpm - 1) ~/ 10 * 10) - bpm;
                      context.read<MetronomeBloc>().add(ChangeBpm(gap));
                    },
                  );
                },
                onLongPressEnd: (_) => _bpmChangeTimer?.cancel(),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: AppColors.buttonBpmControlDefault,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.remove,
                      size: 32,
                      color: AppColors.textButtonSecondary,
                    ),
                    onPressed: () {
                      context.read<MetronomeBloc>().add(ChangeBpm(-1));
                    },
                  ),
                ),
              ),
              const SizedBox(width: 2),

              // BPM Text
              // Bloc 상태를 사용하여 BPM 값을 업데이트
              BlocBuilder<MetronomeBloc, MetronomeState>(
                builder: (context, state) {
                  return SizedBox(
                    width: 136,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                          state.isTapping
                              ? Container(
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundDefault,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  state.bpm.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 58,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textBPMSearch,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              )
                              : Text(
                                state.bpm.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 58,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textButtonSecondary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                    ),
                  );
                },
              ),

              const SizedBox(width: 2),

              // Plus Button
              GestureDetector(
                onLongPressStart: (_) {
                  _bpmChangeTimer = Timer.periodic(
                    const Duration(milliseconds: 100),
                    (_) {
                      final bpm = context.read<MetronomeBloc>().state.bpm;
                      final gap = ((bpm + 10) ~/ 10 * 10) - bpm;
                      context.read<MetronomeBloc>().add(ChangeBpm(gap));
                    },
                  );
                },
                onLongPressEnd: (_) => _bpmChangeTimer?.cancel(),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: AppColors.buttonBpmControlDefault,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.add,
                      size: 32,
                      color: AppColors.textButtonSecondary,
                    ),
                    onPressed: () {
                      context.read<MetronomeBloc>().add(ChangeBpm(1));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Start and Detect Tempo buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: BlocBuilder<MetronomeBloc, MetronomeState>(
                  builder: (context, state) {
                    final isPlaying = state.isPlaying;
                    return ElevatedButton(
                      onPressed: () {
                        if (isPlaying) {
                          context.read<MetronomeBloc>().add(Stop());
                        } else {
                          context.read<MetronomeBloc>().add(Play());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 74),
                        backgroundColor:
                            isPlaying
                                ? AppColors.buttonPlaystop
                                : AppColors.buttonPlaystart,
                      ),
                      child: Text(
                        isPlaying ? "멈춤" : "시작",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                          color:
                              isPlaying
                                  ? AppColors.textButtonPrimary
                                  : AppColors.textButtonEmphasis,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 12),

              // 빠르기 찾기 버튼
              ElevatedButton(
                onPressed: () {
                  context.read<MetronomeBloc>().add(const TapTempo());
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(120, 72),
                  backgroundColor:
                      isTapping
                          ? AppColors.buttonActive
                          : AppColors.buttonPrimary,
                ),
                child: Text(
                  isTapping ? "탭" : "빠르기\n찾기",
                  textAlign: TextAlign.center,
                  style:
                      isTapping
                          ? AppTextStyles.title1R.copyWith(
                            color: AppColors.textButtonEmphasis,
                          )
                          : AppTextStyles.bodyR.copyWith(
                            color: AppColors.textButtonPrimary,
                            height: 1.12,
                          ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget minimumWidget(isTapping) {
    return Column(
      children: [
        // 플마버튼, BPM숫자 row
        GestureDetector(
          onHorizontalDragUpdate: (direction) {
            if (direction.delta.dx < 0) {
              final bpm = context.read<MetronomeBloc>().state.bpm;
              final gap = ((bpm - 1) ~/ 2 * 2) - bpm;
              context.read<MetronomeBloc>().add(ChangeBpm(gap));
            } else if (direction.delta.dx > 0) {
              final bpm = context.read<MetronomeBloc>().state.bpm;
              final gap = ((bpm + 2) ~/ 2 * 2) - bpm;
              context.read<MetronomeBloc>().add(ChangeBpm(gap));
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Minus Button
              GestureDetector(
                onLongPressStart: (_) {
                  _bpmChangeTimer = Timer.periodic(
                    const Duration(milliseconds: 100),
                    (_) {
                      final bpm = context.read<MetronomeBloc>().state.bpm;
                      final gap = ((bpm - 1) ~/ 10 * 10) - bpm;
                      context.read<MetronomeBloc>().add(ChangeBpm(gap));
                    },
                  );
                },
                onTap: () {
                  context.read<MetronomeBloc>().add(ChangeBpm(-1));
                },
                onLongPressEnd: (_) => _bpmChangeTimer?.cancel(),
                child: Icon(
                  Icons.remove,
                  size: 16,
                  color: AppColors.textButtonSecondary,
                ),
              ),
              const SizedBox(width: 2),

              // BPM Text
              // Bloc 상태를 사용하여 BPM 값을 업데이트
              BlocBuilder<MetronomeBloc, MetronomeState>(
                builder: (context, state) {
                  return SizedBox(
                    // width: 100,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                          state.isTapping
                              ? Container(
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundDefault,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  state.bpm.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 44,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textBPMSearch,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              )
                              : Text(
                                state.bpm.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textButtonSecondary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                    ),
                  );
                },
              ),

              // const SizedBox(width: 2),

              // Plus Button
              GestureDetector(
                onLongPressStart: (_) {
                  _bpmChangeTimer = Timer.periodic(
                    const Duration(milliseconds: 100),
                    (_) {
                      final bpm = context.read<MetronomeBloc>().state.bpm;
                      final gap = ((bpm + 10) ~/ 10 * 10) - bpm;
                      context.read<MetronomeBloc>().add(ChangeBpm(gap));
                    },
                  );
                },
                onTap: () {
                  context.read<MetronomeBloc>().add(ChangeBpm(1));
                },
                onLongPressEnd: (_) => _bpmChangeTimer?.cancel(),
                child: Icon(
                  Icons.add,
                  size: 16,
                  color: AppColors.textButtonSecondary,
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (context.read<MetronomeBloc>().state.isPlaying) {
                    context.read<MetronomeBloc>().add(Stop());
                  } else {
                    context.read<MetronomeBloc>().add(Play());
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(88, 74),
                  backgroundColor:
                      context.read<MetronomeBloc>().state.isPlaying
                          ? AppColors.buttonPlaystop
                          : AppColors.buttonPlaystart,
                ),
                child: Center(
                  child:
                      context.read<MetronomeBloc>().state.isPlaying
                          ? Icon(
                            Icons.stop,
                            size: 29,
                            color: AppColors.backgroundDefault,
                          )
                          : Icon(
                            Icons.play_arrow,
                            size: 29,
                            color: AppColors.backgroundDefault,
                          ),
                ),
              ),
              SizedBox(width: 8),
              // 빠르기 찾기 버튼
              ElevatedButton(
                onPressed: () {
                  context.read<MetronomeBloc>().add(const TapTempo());
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(74, 74),
                  backgroundColor:
                      isTapping
                          ? AppColors.buttonActive
                          : AppColors.buttonPrimary,
                ),
                child: Text(
                  "탭",
                  textAlign: TextAlign.center,
                  style:
                      isTapping
                          ? AppTextStyles.title1R.copyWith(
                            color: AppColors.textButtonEmphasis,
                          )
                          : AppTextStyles.bodyR.copyWith(
                            color: AppColors.textButtonPrimary,
                            height: 1.12,
                          ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
