import 'package:flutter/material.dart';
import 'package:hanbae/theme/colors.dart';
import 'package:hanbae/theme/text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanbae/bloc/metronome/metronome_bloc.dart';
import 'dart:async';
import 'dart:math';

import 'package:hive/hive.dart';

class MetronomeControl extends StatefulWidget {
  final double iconSize;
  const MetronomeControl({super.key, required this.iconSize});

  @override
  _MetronomeControlState createState() => _MetronomeControlState();
}

class _MetronomeControlState extends State<MetronomeControl> {
  @override
  Widget build(BuildContext context) {
    final metronomeState = context.watch<MetronomeBloc>().state;
    final isTapping = metronomeState.isTapping;
    final minimum = metronomeState.minimum;

    return Container(
      margin: const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // '빠르기(BPM)' 텍스트 애니메이션
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: minimum ? 0 : 32,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: minimum ? 0 : 1,
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
            ),
            AnimatedMetronomeLayout(minimum: minimum, isTapping: isTapping),
          ],
        ),
      ),
    );
  }
}

/// 레이아웃 전환 애니메이션을 담당하는 위젯
class AnimatedMetronomeLayout extends StatelessWidget {
  final bool minimum;
  final bool isTapping;

  const AnimatedMetronomeLayout({
    super.key,
    required this.minimum,
    required this.isTapping,
  });

  // 위젯 크기 및 간격 상수 정의
  static const double _mainBpmHeight = 74.0;
  static const double _mainActionsHeight = 74.0;
  static const double _mainBpmWidth = 240.0; // +,- 버튼 포함 너비
  static const double _mainActionsWidth = 300.0; // 시작/탭 버튼 너비

  static const double _minBpmHeight = 60.0;
  static const double _minActionsHeight = 74.0;
  static const double _minBpmWidth = 140.0;
  static const double _minActionsWidth = 170.0;

  static const double _spacing = 8.0;

  @override
  Widget build(BuildContext context) {
    final double canvasWidth =
        minimum
            ? _minBpmWidth + _minActionsWidth + _spacing
            : max(_mainBpmWidth, _mainActionsWidth);

    final double canvasHeight =
        minimum
            ? max(_minBpmHeight, _minActionsHeight)
            : _mainBpmHeight + _mainActionsHeight + _spacing + 20;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: canvasWidth,
      height: canvasHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // BPM
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            width: minimum ? _minBpmWidth : _mainBpmWidth,
            height: minimum ? _minBpmHeight : _mainBpmHeight,
            top: minimum ? (canvasHeight - _minBpmHeight) / 2 + 8 : 8,
            left: minimum ? 0 : (canvasWidth - _mainBpmWidth) / 2,
            child: _BpmControls(minimum: minimum, isTapping: isTapping),
          ),
          // 속도
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            width: minimum ? _minActionsWidth : _mainActionsWidth,
            height: minimum ? _minActionsHeight : _mainActionsHeight,
            top:
                minimum
                    ? (canvasHeight - _minActionsHeight) / 2
                    : _mainBpmHeight + _spacing + 12,
            left:
                minimum
                    ? _minBpmWidth + _spacing
                    : (canvasWidth - _mainActionsWidth) / 2,
            child: ActionButtons(minimum: minimum, isTapping: isTapping),
          ),
        ],
      ),
    );
  }
}

class _BpmControls extends StatefulWidget {
  final bool minimum;
  final bool isTapping;

  const _BpmControls({required this.minimum, required this.isTapping});

  @override
  __BpmControlsState createState() => __BpmControlsState();
}

class __BpmControlsState extends State<_BpmControls> {
  Timer? _bpmChangeTimer;

  @override
  void dispose() {
    _bpmChangeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Minus Button
          GestureDetector(
            onTap: () => context.read<MetronomeBloc>().add(ChangeBpm(-1)),
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
            child:
                widget.minimum
                    ? const Icon(
                      Icons.remove,
                      size: 24,
                      color: AppColors.textButtonSecondary,
                    )
                    : Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: AppColors.buttonBpmControlDefault,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.remove,
                        size: 32,
                        color: AppColors.textButtonSecondary,
                      ),
                    ),
          ),

          // BPM Text
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: widget.minimum ? 90 : 120,
            height: widget.minimum ? 60 : 74,
            decoration: BoxDecoration(
              color:
                  widget.isTapping
                      ? AppColors.backgroundDefault
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                context.read<MetronomeBloc>().state.bpm.toString(),
                // textAlign: TextAlign.center,
                // style: textStyle.copyWith(
                //   color:
                //   widget.isTapping
                //       ? AppColors.textBPMSearch
                //       : AppColors.textButtonSecondary,
                // ),
                style: TextStyle(
                  color:
                      widget.isTapping
                          ? AppColors.textBPMSearch
                          : AppColors.textButtonSecondary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.5,
                  fontSize: widget.minimum ? 44 : 58,
                ),
              ),
            ),
          ),
          // BlocBuilder<MetronomeBloc, MetronomeState>(
          //   builder: (context, state) {
          //     final textStyle =
          //         widget.minimum
          //             ? const TextStyle(
          //               fontSize: 44,
          //               fontWeight: FontWeight.w500,
          //               letterSpacing: -0.5,
          //             )
          //             : const TextStyle(
          //               fontSize: 58,
          //               fontWeight: FontWeight.w500,
          //               letterSpacing: -0.5,
          //             );
          //
          //     return ;
          //   },
          // ),

          // Plus Button
          GestureDetector(
            onTap: () => context.read<MetronomeBloc>().add(ChangeBpm(1)),
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
            child:
                widget.minimum
                    ? const Icon(
                      Icons.add,
                      size: 24,
                      color: AppColors.textButtonSecondary,
                    )
                    : Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: AppColors.buttonBpmControlDefault,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 32,
                        color: AppColors.textButtonSecondary,
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

/// 액션 버튼
class ActionButtons extends StatelessWidget {
  final bool minimum;
  final bool isTapping;

  const ActionButtons({
    super.key,
    required this.minimum,
    required this.isTapping,
  });

  @override
  Widget build(BuildContext context) {
    if (minimum) {
      // Minimum 모드 (가로 배치)
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildPlayStopButton(context, isMinimum: true),
          const SizedBox(width: 8),
          _buildTapButton(context, isMinimum: true),
        ],
      );
    } else {
      // Main 모드 세로
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: buildPlayStopButton(context, isMinimum: false)),
          const SizedBox(width: 12),
          _buildTapButton(context, isMinimum: false),
        ],
      );
    }
  }

  Widget buildPlayStopButton(BuildContext context, {required bool isMinimum}) {
    return BlocBuilder<MetronomeBloc, MetronomeState>(
      builder: (context, state) {
        final isPlaying = state.isPlaying;
        return ElevatedButton(
          onPressed: () {
            context.read<MetronomeBloc>().add(isPlaying ? Stop() : Play());
          },
          style: ElevatedButton.styleFrom(
            minimumSize: isMinimum ? const Size(88, 74) : const Size(0, 74),
            backgroundColor:
                isPlaying
                    ? AppColors.buttonPlaystop
                    : AppColors.buttonPlaystart,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          child:
              isMinimum
                  ? Icon(
                    isPlaying ? Icons.stop : Icons.play_arrow,
                    size: 29,
                    color: AppColors.backgroundDefault,
                  )
                  : Text(
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
    );
  }

  Widget _buildTapButton(BuildContext context, {required bool isMinimum}) {
    return ElevatedButton(
      onPressed: () {
        context.read<MetronomeBloc>().add(const TapTempo());
      },
      style: ElevatedButton.styleFrom(
        fixedSize: isMinimum ? const Size(74, 74) : const Size(110, 74),
        backgroundColor:
            isTapping ? AppColors.buttonActive : AppColors.buttonPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
      child: Text(
        isMinimum
            ? "탭"
            : isTapping
            ? "탭"
            : "빠르기\n찾기",
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
    );
    // return InkWell(
    //   onTap: () {
    //     context.read<MetronomeBloc>().add(const TapTempo());
    //   },
    //   child: Container(
    //     width: 100,
    //     decoration: BoxDecoration(
    //       color: isTapping ? AppColors.buttonActive : AppColors.buttonPrimary,
    //     ),
    //     child: Text(
    //       isMinimum
    //           ? "탭"
    //           : isTapping
    //           ? "탭"
    //           : "빠르기\n찾기",
    //       textAlign: TextAlign.center,
    //       style:
    //           isTapping
    //               ? AppTextStyles.title1R.copyWith(
    //                 color: AppColors.textButtonEmphasis,
    //               )
    //               : AppTextStyles.bodyR.copyWith(
    //                 color: AppColors.textButtonPrimary,
    //                 height: 1.12,
    //               ),
    //     ),
    //   ),
    // );
  }
}
