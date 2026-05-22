import 'package:flutter/material.dart';
import 'package:hanbae/presentation/sequence/jangdan_sequence_create_screen.dart';
import 'package:hanbae/theme/colors.dart';
import 'package:hanbae/theme/text_styles.dart';
import 'package:hanbae/utils/local_storage.dart';

class JangdanSequenceOnboardingScreen extends StatefulWidget {
  const JangdanSequenceOnboardingScreen({super.key});

  @override
  State<JangdanSequenceOnboardingScreen> createState() =>
      _JangdanSequenceOnboardingScreenState();
}

class _JangdanSequenceOnboardingScreenState
    extends State<JangdanSequenceOnboardingScreen> {
  @override
  void initState() {
    super.initState();
    Storage().setSequenceOnboardingSeen();
  }

  Future<void> _start(BuildContext context) async {
    await Storage().setSequenceOnboardingSeen();
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const JangdanSequenceCreateScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDefault,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/img_Sequence_Onboarding.png',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 60),
              child: Column(
                children: [
                  const Spacer(flex: 19),
                  _FeatureHeader(),
                  const SizedBox(height: 120),
                  const _FeatureList(),
                  const Spacer(flex: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: () => _start(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.brandHeavy,
                        foregroundColor: AppColors.labelPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '장단 이어서 만들기',
                        style: AppTextStyles.bodySb.copyWith(
                          color: AppColors.labelPrimary,
                          fontSize: 17,
                          height: 22 / 17,
                          letterSpacing: -0.43,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.neutral9,
            borderRadius: BorderRadius.circular(500),
          ),
          child: Text(
            '새로운 기능!',
            style: AppTextStyles.subheadlineSb.copyWith(
              color: AppColors.labelDefault,
              fontSize: 15,
              height: 20 / 15,
              letterSpacing: -0.23,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '여러 장단을 순서대로 이어서,\n실제 연주처럼 연습할 수 있어요!',
          textAlign: TextAlign.center,
          style: AppTextStyles.title2B.copyWith(
            color: AppColors.labelPrimary,
            fontSize: 22,
            height: 28 / 22,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}

class _FeatureList extends StatelessWidget {
  const _FeatureList();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _FeatureItem(
            icon: Icons.music_note_rounded,
            text: '원하는 장단을 골라 순서를 만들고',
          ),
          SizedBox(height: 16),
          _FeatureItem(icon: Icons.replay_rounded, text: '각 장단의 반복 횟수를 설정하면'),
          SizedBox(height: 16),
          _FeatureItem(
            icon: Icons.play_circle_fill_rounded,
            text: '끊기지 않고 이어서 재생돼요!',
          ),
          SizedBox(height: 16),
          _FeatureItem(
            icon: Icons.create_new_folder_rounded,
            text: '저장해두고 다시 연습할 수 있어요!',
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppColors.labelPrimary),
        const SizedBox(width: 10),
        Text(
          text,
          style: AppTextStyles.bodyR.copyWith(
            color: AppColors.labelPrimary,
            fontSize: 17,
            height: 22 / 17,
            letterSpacing: -0.43,
          ),
        ),
      ],
    );
  }
}
