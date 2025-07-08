import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanbae/model/jangdan_type.dart';
import 'package:hanbae/theme/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hanbae/theme/text_styles.dart';
import 'dart:ui'; // Ensure this import is present
import '../../bloc/metronome/metronome_bloc.dart';
import 'package:hanbae/model/sound.dart';

class MetronomeOptions extends StatefulWidget {
  const MetronomeOptions({super.key});

  @override
  _MetronomeOptionsState createState() => _MetronomeOptionsState();
}

class _MetronomeOptionsState extends State<MetronomeOptions> {
  bool _isSoundMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 소박 토글
        BlocBuilder<MetronomeBloc, MetronomeState>(
          builder: (context, state) {
            final isOn = state.isSobakOn;
            return Expanded(
              child: Container(
                height: 50,
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color:
                      isOn
                          ? AppColors.backgroundCard
                          : AppColors.buttonToggleOff,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      isOn
                          ? Border.all(
                            color: AppColors.buttonToggleOn,
                            width: 1,
                          )
                          : null,
                ),
                child: IconButton(
                  icon: SvgPicture.asset(
                    state.selectedJangdan.jangdanType.sobakSegmentCount == null
                        ? 'assets/images/icon/Icon_ListenSobak.svg'
                        : 'assets/images/icon/Icon_ViewSobak.svg',
                    width: 32,
                    height: 32,
                    colorFilter: ColorFilter.mode(
                      isOn ? AppColors.buttonToggleOn : AppColors.textSecondary,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: () {
                    context.read<MetronomeBloc>().add(ToggleSobak());
                  },
                ),
              ),
            );
          },
        ),

        const SizedBox(width: 8),

        // 화면 반짝임 토글
        BlocBuilder<MetronomeBloc, MetronomeState>(
          builder: (context, state) {
            final isOn = state.isFlashOn;
            return Expanded(
              child: Container(
                height: 50,
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color:
                      isOn
                          ? AppColors.backgroundCard
                          : AppColors.buttonToggleOff,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      isOn
                          ? Border.all(
                            color: AppColors.buttonToggleOn,
                            width: 1,
                          )
                          : null,
                ),
                child: IconButton(
                  icon: SvgPicture.asset(
                    'assets/images/icon/Icon_Flash.svg',
                    width: 32,
                    height: 32,
                    colorFilter: ColorFilter.mode(
                      isOn ? AppColors.buttonToggleOn : AppColors.textSecondary,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: () {
                    context.read<MetronomeBloc>().add(ToggleFlash());
                  },
                ),
              ),
            );
          },
        ),

        const SizedBox(width: 8),

        // 소리 변경 토글
        Expanded(
          child: Container(
            height: 50,
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color:
                  _isSoundMenuOpen
                      ? AppColors.backgroundCard
                      : AppColors.buttonToggleOff,
              borderRadius: BorderRadius.circular(12),
              border:
                  _isSoundMenuOpen
                      ? Border.all(color: AppColors.buttonToggleOn, width: 1)
                      : null,
            ),
            child: PopupMenuButton<Sound>(
              color: AppColors.backgroundPopupMenu,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/images/icon/Icon_SoundSwitch.svg',
                    width: 32,
                    height: 32,
                    colorFilter: ColorFilter.mode(
                      _isSoundMenuOpen
                          ? AppColors.buttonToggleOn
                          : AppColors.textSecondary,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    context
                        .select((MetronomeBloc bloc) => bloc.state.currentSound)
                        .label,
                    style: AppTextStyles.bodyR.copyWith(
                      color:
                          _isSoundMenuOpen
                              ? AppColors.buttonToggleOn
                              : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              onCanceled: () {
                setState(() => _isSoundMenuOpen = false);
              },
              onSelected: (value) {
                setState(() => _isSoundMenuOpen = false);
                context.read<MetronomeBloc>().add(ChangeSound(value));
              },
              itemBuilder:
                  (ctx) => const [
                    PopupMenuItem(
                      value: Sound.janggu,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text('장구', style: AppTextStyles.bodyR),
                    ),
                    PopupMenuItem(
                      value: Sound.buk,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text('북', style: AppTextStyles.bodyR),
                    ),
                    PopupMenuItem(
                      value: Sound.clave,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text('나무', style: AppTextStyles.bodyR),
                    ),
                  ],
              onOpened: () {
                setState(() => _isSoundMenuOpen = true);
              },
            ),
          ),
        ),
        SizedBox(width: 14),
        SizedBox(
          width: 60,
          height: 66,
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                child: InkWell(
                  onTap: () {
                    context.read<MetronomeBloc>().add(const ToggleMinimum());
                  },
                  child: Container(
                    width: 60,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCard,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: BlocBuilder<MetronomeBloc, MetronomeState>(
                      builder: (context, state) {
                        return Center(
                          child: Icon(
                            context.read<MetronomeBloc>().state.minimum
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 36,
                            color: AppColors.textQuaternary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                child: SizedBox(
                  width: 60,
                  child: SvgPicture.asset('assets/images/icon/new_icon.svg'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
