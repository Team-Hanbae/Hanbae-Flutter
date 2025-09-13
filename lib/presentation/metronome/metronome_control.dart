import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:flutter/material.dart';
import 'package:hanbae/theme/colors.dart';
import 'package:hanbae/theme/text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import the flutter_bloc package
import 'package:hanbae/bloc/metronome/metronome_bloc.dart'; // Import the MetronomeBloc
import 'package:hero_animation/hero_animation.dart';
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
    final minimum = context.read<MetronomeBloc>().state.minimum;
    final isPlaying = context.read<MetronomeBloc>().state.isPlaying;

    return Container(
      margin: const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundMute,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),

      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: GestureDetector(
            onHorizontalDragUpdate: (direction) {
              int gestureSpeed = 2;
              if (minimum) {
                gestureSpeed = 1;
              }
              if (direction.delta.dx < 0) {
                final bpm = context.read<MetronomeBloc>().state.bpm;
                final gap = ((bpm - 1) ~/ gestureSpeed * gestureSpeed) - bpm;
                context.read<MetronomeBloc>().add(ChangeBpm(gap));
              } else if (direction.delta.dx > 0) {
                final bpm = context.read<MetronomeBloc>().state.bpm;
                final gap = ((bpm + 2) ~/ gestureSpeed * gestureSpeed) - bpm;
                context.read<MetronomeBloc>().add(ChangeBpm(gap));
              }
            },
            child: Column(
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: double.infinity,
                  height: minimum ? 0 : 28,
                  decoration: BoxDecoration(),
                  child: Center(
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
                                  color: AppColors.labelPrimary
                                ),
                              ),
                            )
                            : Text(
                              '빠르기(BPM)',
                              style: AppTextStyles.calloutR.copyWith(
                                color: AppColors.labelSecondary,
                              ),
                            ),
                  ),
                ),
                metronomeControlWidget(isTapping, minimum, isPlaying),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget metronomeControlWidget(isTapping, minimum, isPlaying) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      width: double.infinity,
      height: minimum ? 80 : 182,
      child: HeroAnimationScene(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        child:
            minimum
                ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      HeroAnimation.child(
                        tag: '0',
                        key: ValueKey(0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Minus Button
                            minusButton(),

                            // BPM Text
                            // Bloc 상태를 사용하여 BPM 값을 업데이트
                            showBpmWidget(),

                            // const SizedBox(width: 2),

                            // Plus Button
                            plusButton(),
                            SizedBox(width: 8),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: HeroAnimation.child(
                          tag: '1',
                          key: ValueKey(1),
                          child: playButton(),
                        ),
                      ),
                      SizedBox(width: 8),
                      HeroAnimation.child(
                        tag: '2',
                        key: ValueKey(2),
                        child: tempoButton(),
                      ),
                    ],
                  ),
                )
                : Column(
                  children: [
                    // 플마버튼, BPM숫자 row
                    HeroAnimation.child(
                      tag: '0',
                      key: ValueKey(0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // Minus Button
                          minusButton(),

                          const SizedBox(width: 2),
                          showBpmWidget(),

                          const SizedBox(width: 2),

                          // Plus Button
                          plusButton(),
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
                            child: HeroAnimation.child(
                              tag: '1',
                              key: ValueKey(1),
                              child: playButton(),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // 빠르기 찾기 버튼
                          HeroAnimation.child(
                            tag: '2',
                            key: ValueKey(2),
                            child: tempoButton(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget playButton() {
    return BlocBuilder<MetronomeBloc, MetronomeState>(
      buildWhen:
          (previous, current) =>
              previous.isPlaying != current.isPlaying ||
              previous.minimum != current.minimum,
      builder: (context, state) {
        final isPlaying = state.isPlaying;
        final minimum = state.minimum;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child:
              minimum
                  ? ElevatedButton(
                    key: const ValueKey('min_play_button'),
                    onPressed: () {
                      context.read<MetronomeBloc>().add(
                        isPlaying ? Stop() : Play(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(double.infinity, 74),
                      backgroundColor:
                          isPlaying
                              ? AppColors.buttonDefault
                              : AppColors.buttonInverse,
                    ),
                    child: Center(
                      child: Icon(
                        isPlaying ? Icons.stop : Icons.play_arrow,
                        size: 29,
                        color:
                            isPlaying
                                ? AppColors.labelPrimary
                                : AppColors.labelInverse,
                      ),
                    ),
                  )
                  : ElevatedButton(
                    key: const ValueKey('main_play_button'),
                    onPressed: () {
                      context.read<MetronomeBloc>().add(
                        isPlaying ? Stop() : Play(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 74),
                      backgroundColor:
                          isPlaying
                              ? AppColors.buttonDefault
                              : AppColors.buttonInverse,
                    ),
                    child: Text(
                      isPlaying ? "멈춤" : "시작",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                        color:
                            isPlaying
                                ? AppColors.labelPrimary
                                : AppColors.labelInverse,
                      ),
                    ),
                  ),
        );
      },
    );
  }

  Widget tempoButton() {
    return BlocBuilder<MetronomeBloc, MetronomeState>(
      buildWhen:
          (previous, current) =>
              previous.isTapping != current.isTapping ||
              previous.minimum != current.minimum,
      builder: (context, state) {
        final minimum = state.minimum;
        final isTapping = state.isTapping;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child:
              minimum
                  ? ElevatedButton(
                    key: ValueKey('min_tempo_button'),
                    onPressed: () {
                      context.read<MetronomeBloc>().add(const TapTempo());
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(74, 74),
                      backgroundColor:
                          isTapping
                              ? AppColors.themeNormal
                              : AppColors.buttonDefault,
                    ),
                    child: Text(
                      "탭",
                      textAlign: TextAlign.center,
                      style:
                          isTapping
                              ? AppTextStyles.bodyR.copyWith(
                                color: AppColors.labelInverse,
                              )
                              : AppTextStyles.bodyR.copyWith(
                                color: AppColors.labelPrimary,
                              ),
                    ),
                  )
                  : ElevatedButton(
                    key: ValueKey('main_tempo_button'),
                    onPressed: () {
                      context.read<MetronomeBloc>().add(const TapTempo());
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(112, 74),
                      backgroundColor:
                          isTapping
                              ? AppColors.themeNormal
                              : AppColors.buttonDefault,
                    ),
                    child: Text(
                      isTapping ? "탭" : "빠르기\n찾기",
                      textAlign: TextAlign.center,
                      style:
                          isTapping
                              ? AppTextStyles.title1R.copyWith(
                                color: AppColors.labelInverse,
                              )
                              : AppTextStyles.bodyR.copyWith(
                                color: AppColors.labelPrimary,
                                height: 1.12,
                              ),
                    ),
                  ),
        );
      },
    );
  }

  Widget minusButton() {
    return BlocBuilder<MetronomeBloc, MetronomeState>(
      buildWhen:
          (previous, current) =>
              previous.isPlaying != current.isPlaying ||
              previous.minimum != current.minimum ||
              previous.bpm != current.bpm,
      builder: (context, state) {
        final isPlaying = state.isPlaying;
        final minimum = state.minimum;
        final bpm = state.bpm;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child:
              minimum
                  ? GestureDetector(
                    key: ValueKey('min_minus_button'),
                    onLongPressStart: (_) {
                      _bpmChangeTimer = Timer.periodic(
                        const Duration(milliseconds: 100),
                        (_) {
                          // final bpm = context.read<MetronomeBloc>().state.bpm;
                          final gap = ((bpm - 1) ~/ 10 * 10) - bpm;
                          context.read<MetronomeBloc>().add(ChangeBpm(gap));
                        },
                      );
                    },
                    onTap: () {
                      context.read<MetronomeBloc>().add(ChangeBpm(-1));
                    },
                    onLongPressEnd: (_) => _bpmChangeTimer?.cancel(),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.remove,
                        size: 16,
                        color: AppColors.labelTertiary,
                      ),
                    ),
                  )
                  : GestureDetector(
                    key: ValueKey('main_minus_button'),
                    onLongPressStart: (_) {
                      _bpmChangeTimer = Timer.periodic(
                        const Duration(milliseconds: 100),
                        (_) {
                          // final bpm = context.read<MetronomeBloc>().state.bpm;
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
                        color: AppColors.buttonMute,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.remove,
                          size: 32,
                          color: AppColors.labelDefault,
                        ),
                        onPressed: () {
                          context.read<MetronomeBloc>().add(ChangeBpm(-1));
                        },
                      ),
                    ),
                  ),
        );
      },
    );
  }

  Widget showBpmWidget() {
    return BlocBuilder<MetronomeBloc, MetronomeState>(
      buildWhen:
          (previous, current) =>
              previous.isPlaying != current.isPlaying ||
              previous.minimum != current.minimum ||
              previous.isTapping != current.isTapping ||
              previous.bpm != current.bpm,
      builder: (context, state) {
        final isPlaying = state.isPlaying;
        final minimum = state.minimum;
        final isTapping = state.isTapping;
        final bpm = state.bpm;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child:
              minimum
                  ? SizedBox(
                    key: ValueKey('min_bpm'),
                    width: 90,
                    child:
                        isTapping
                            ? Container(
                              decoration: BoxDecoration(
                                color: AppColors.backgroundDefault,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                bpm.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.themeNormal,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            )
                            : Text(
                              bpm.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w500,
                                color: AppColors.labelDefault,
                                letterSpacing: -0.5,
                              ),
                            ),
                  )
                  : SizedBox(
                    key: ValueKey('main_bpm'),
                    width: 136,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                          isTapping
                              ? Container(
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundDefault,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  bpm.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 58,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.themeNormal,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              )
                              : Text(
                                bpm.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 58,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.labelDefault,
                                  letterSpacing: -0.5,
                                ),
                              ),
                    ),
                  ),
        );
      },
    );
  }

  Widget plusButton() {
    return BlocBuilder<MetronomeBloc, MetronomeState>(
      buildWhen:
          (previous, current) =>
              previous.isPlaying != current.isPlaying ||
              previous.minimum != current.minimum ||
              previous.bpm != current.bpm,
      builder: (context, state) {
        final isPlaying = state.isPlaying;
        final minimum = state.minimum;
        final bpm = state.bpm;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child:
              minimum
                  ? GestureDetector(
                    key: ValueKey('min_plus_button'),
                    onLongPressStart: (_) {
                      _bpmChangeTimer = Timer.periodic(
                        const Duration(milliseconds: 100),
                        (_) {
                          // final bpm = context.read<MetronomeBloc>().state.bpm;
                          final gap = ((bpm + 10) ~/ 10 * 10) - bpm;
                          context.read<MetronomeBloc>().add(ChangeBpm(gap));
                        },
                      );
                    },
                    onTap: () {
                      context.read<MetronomeBloc>().add(ChangeBpm(1));
                    },
                    onLongPressEnd: (_) => _bpmChangeTimer?.cancel(),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.add,
                        size: 16,
                        color: AppColors.labelTertiary,
                      ),
                    ),
                  )
                  : GestureDetector(
                    key: ValueKey('main_plus_button'),
                    onLongPressStart: (_) {
                      _bpmChangeTimer = Timer.periodic(
                        const Duration(milliseconds: 100),
                        (_) {
                          // final bpm = context.read<MetronomeBloc>().state.bpm;
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
                        color: AppColors.buttonMute,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.add,
                          size: 32,
                          color: AppColors.labelDefault,
                        ),
                        onPressed: () {
                          context.read<MetronomeBloc>().add(ChangeBpm(1));
                        },
                      ),
                    ),
                  ),
        );
      },
    );
  }
}
