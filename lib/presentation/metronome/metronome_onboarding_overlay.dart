import 'package:flutter/material.dart';
import 'package:hanbae/presentation/metronome/hanbae_board.dart';
import 'package:hanbae/theme/colors.dart';
import 'package:hanbae/theme/text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

class MetronomeOnboardingOverlay extends StatelessWidget {
  final int step;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const MetronomeOnboardingOverlay({
    super.key,
    required this.step,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final content = _stepContent(step);
    final isLast = step >= 3;

    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onNext,
              child: Container(color: AppColors.dimmerHeavy),
            ),
            _buildHighlight(context, size),
            _buildLottie(step),
            _buildFloatingText(context, content, isLast),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlight(BuildContext context, Size size) {
    switch (step) {
      case 0:
        return Positioned(
          top: 72,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: SizedBox(
              height: size.height * 0.45,
              child: Column(children: [HanbaeBoard()]),
            ),
          ),
        );
      case 1:
        return Positioned(
          left: 16,
          right: 16,
          bottom: 130,
          child: IgnorePointer(child: _OnboardingBpmControl()),
        );
      case 2:
        return Positioned(
          right: 28,
          bottom: 110,
          child: IgnorePointer(child: _OnboardingTempoButton()),
        );
      case 3:
        return Positioned(
          left: 16,
          right: 16,
          bottom: 324,
          child: IgnorePointer(child: _OnboardingOptionsShort()),
        );
      default:
        return Positioned(
          left: 16,
          right: 16,
          child: IgnorePointer(child: _OnboardingOptionsShort()),
        );
    }
  }

  Widget _buildFloatingText(
    BuildContext context,
    _OnboardingContent content,
    bool isLast,
  ) {
    final position = _textPositionForStep(step);
    return Positioned(
      left: position.left,
      right: position.right,
      top: position.top,
      bottom: position.bottom,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            content.description,
            style: AppTextStyles.title3Sb.copyWith(
              color: AppColors.labelDefault,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 60,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Text(
                    '다음',
                    style: AppTextStyles.bodyR.copyWith(
                      color: AppColors.labelDefault,
                    ),
                  ),
                  Positioned(
                    right: -10,
                    child: Image.asset(
                      'assets/images/icon/Onboarding_Next.png',
                      width: 22,
                      height: 28,
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

  Widget _buildLottie(int step) {
    final config = _lottieConfigForStep(step);
    if (config == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: config.position.left,
      right: config.position.right,
      top: config.position.top,
      bottom: config.position.bottom,
      child: IgnorePointer(
        child: SizedBox(
          width: config.width,
          height: config.height,
          child: Lottie.asset(config.asset, repeat: true),
        ),
      ),
    );
  }

  _OnboardingContent _stepContent(int step) {
    switch (step) {
      case 0:
        return _OnboardingContent(description: '막대 높이를 터치하여\n강세를 변경할 수 있어요');
      case 1:
        return _OnboardingContent(
          description: '빠르기 영역을 좌우로 조절해\n쉽게 빠르기를 변경할 수 있어요',
        );
      case 2:
        return _OnboardingContent(
          description: '원하는 속도로 버튼을 클릭하면\n해당 빠르기로 바로 설정할 수 있어요',
        );
      case 3:
        return _OnboardingContent(
          description: '여러 옵션을 통해\n다양한 방식으로 메트로놈을\n사용할 수 있어요.',
        );
      default:
        return _OnboardingContent(
          description: '여러 옵션을 통해\n다양한 방식으로 메트로놈을\n사용할 수 있어요.',
        );
    }
  }

  _TextPosition _textPositionForStep(int step) {
    switch (step) {
      case 0:
        return const _TextPosition(left: 20, right: 20, bottom: 250);
      case 1:
        return const _TextPosition(left: 20, right: 20, top: 400);
      case 2:
        return const _TextPosition(left: 20, right: 20, bottom: 240);
      case 3:
        return const _TextPosition(left: 20, right: 20, top: 280);
      default:
        return const _TextPosition(left: 20, right: 20, top: 280);
    }
  }

  _LottieConfig? _lottieConfigForStep(int step) {
    switch (step) {
      case 0:
        return const _LottieConfig(
          asset: 'assets/lotties/repeat_touch.json',
          position: _TextPosition(left: 24, right: 24, top: 260),
          width: 110,
          height: 115,
        );
      case 1:
        return const _LottieConfig(
          asset: 'assets/lotties/scroll_horizontal.json',
          position: _TextPosition(right: 18, bottom: 80),
          width: 256,
          height: 128,
        );
      case 2:
        return const _LottieConfig(
          asset: 'assets/lotties/repeat_touch.json',
          position: _TextPosition(right: 0, bottom: 35),
          width: 110,
          height: 115,
        );
      default:
        return null;
    }
  }
}

class _OnboardingContent {
  final String description;

  const _OnboardingContent({required this.description});
}

class _TextPosition {
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;

  const _TextPosition({this.left, this.right, this.top, this.bottom});
}

class _LottieConfig {
  final String asset;
  final _TextPosition position;
  final double width;
  final double height;

  const _LottieConfig({
    required this.asset,
    required this.position,
    required this.width,
    required this.height,
  });
}

class _OnboardingTempoButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 74,
      decoration: BoxDecoration(
        color: AppColors.buttonDefault,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.brandNormal, width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        '빠르기\n찾기',
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyR.copyWith(
          color: AppColors.labelPrimary,
          height: 1.12,
        ),
      ),
    );
  }
}

class _OnboardingBpmControl extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundMute,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: AppColors.brandNormal, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '빠르기(BPM)',
            style: AppTextStyles.calloutR.copyWith(
              color: AppColors.labelSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: AppColors.buttonMute,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.remove,
                  size: 32,
                  color: AppColors.labelDefault,
                ),
              ),
              const SizedBox(
                width: 136,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    '120',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 58,
                      fontWeight: FontWeight.w500,
                      color: AppColors.labelDefault,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: AppColors.buttonMute,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  size: 32,
                  color: AppColors.labelDefault,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OnboardingOptionsShort extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _optionButton('assets/images/icon/Icon_ViewSobak.svg'),
        const SizedBox(width: 8),
        _optionButton('assets/images/icon/Icon_Flash.svg'),
        const SizedBox(width: 8),
        _optionButton('assets/images/icon/reserve_beat_icon.svg'),
        const SizedBox(width: 8),
        _soundOptionButton(),
        const SizedBox(width: 60),
      ],
    );
  }

  Widget _optionButton(String asset) {
    return Expanded(
      child: Container(
        height: 50,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.buttonDefault,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.brandNormal, width: 1),
        ),
        child: Center(
          child: SvgPicture.asset(
            asset,
            width: 32,
            height: 32,
            colorFilter: const ColorFilter.mode(
              AppColors.labelDefault,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  Widget _soundOptionButton() {
    return SizedBox(
      width: 70,
      child: Container(
        height: 50,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.buttonDefault,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.brandNormal, width: 1),
        ),
        child: Center(
          child: Text(
            '장구1',
            style: AppTextStyles.bodyR.copyWith(
              color: AppColors.labelDefault,
            ),
          ),
        ),
      ),
    );
  }
}
