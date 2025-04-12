import 'package:flutter/material.dart';
import 'package:hanbae/theme/colors.dart';
import 'package:hanbae/theme/text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import the flutter_bloc package
import 'package:hanbae/bloc/metronome/metronome_bloc.dart'; // Import the MetronomeBloc

class MetronomeControl extends StatelessWidget {
  const MetronomeControl({super.key});

  @override
  Widget build(BuildContext context) {
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
                Text(
                  '빠르기(BPM)',
                  style: AppTextStyles.calloutR.copyWith(
                    color: AppColors.textTertiary,
                    // backgroundColor: Colors.yellow,
                  ),
                ),

                // const SizedBox(height: 8),

                // 플마버튼, BPM숫자 row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Minus Button
                    Container(
                      width: 56,
                      height: 56,
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
                    const SizedBox(width: 12),

                    // BPM Text
                    // Bloc 상태를 사용하여 BPM 값을 업데이트
                    BlocBuilder<MetronomeBloc, MetronomeState>(
                      builder: (context, state) {
                        return SizedBox(
                          width: 136,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              state.bpm.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textButtonSecondary,
                                letterSpacing: -0.5
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(width: 12),

                    // Plus Button
                    Container(
                      width: 56,
                      height: 56,
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
                  ],
                ),

                // Start and Detect Tempo buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final isPlaying = context.read<MetronomeBloc>().state.isPlaying;
                            if (isPlaying) {
                              context.read<MetronomeBloc>().add(Stop());
                            } else {
                              context.read<MetronomeBloc>().add(Play());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 80),
                            backgroundColor: AppColors.buttonPlaystart,
                          ),
                          child: const Text(
                            "시작",
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textButtonEmphasis,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(120, 80),
                          backgroundColor: AppColors.buttonPrimary,
                        ),
                        child: Text(
                          "빠르기\n찾기",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyR.copyWith(
                            color: AppColors.textButtonPrimary,
                            height: 1.12
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
