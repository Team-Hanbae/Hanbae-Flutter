import 'package:flutter/material.dart';
import 'package:hanbae/theme/colors.dart';
import 'package:hanbae/theme/text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import the flutter_bloc package
import 'package:hanbae/bloc/metronome/metronome_bloc.dart'; // Import the MetronomeBloc
import 'dart:async'; // Import the async package for Timer

class MetronomeControl extends StatefulWidget {
  const MetronomeControl({super.key});

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

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
        ),

        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 32,
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

                // const SizedBox(height: 8),

                // 플마버튼, BPM숫자 row
                Row(
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
                    const SizedBox(width: 12),

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
                                          fontSize: 64,
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
                                        fontSize: 64,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textButtonSecondary,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(width: 12),

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
                          icon: const Icon(
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
                                minimumSize: const Size(0, 72),
                                backgroundColor: isPlaying
                                    ? AppColors.buttonPlaystop
                                    : AppColors.buttonPlaystart,
                              ),
                              child: Text(
                                isPlaying ? "멈춤" : "시작",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w500,
                                  color: isPlaying
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
            ),
          ),
        ),
      ),
    );
  }
}
