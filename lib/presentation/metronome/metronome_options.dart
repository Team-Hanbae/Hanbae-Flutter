import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanbae/model/jangdan_type.dart';
import 'package:hanbae/theme/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hanbae/theme/text_styles.dart';
import 'package:hanbae/utils/animation.dart';
import 'package:hanbae/utils/local_storage.dart';
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
  bool showNewMinimumIcon = false;

  @override
  void initState() {
    super.initState();
    Storage().getReserveBeat().then((value) {
      if (!mounted) return;
      setState(() {
        context.read<MetronomeBloc>().add(
          ToggleReserveBeat(reserveBeat: value),
        );
      });
    });
    Storage().getFirstMinimumCheck().then((value) {
      setState(() {
        showNewMinimumIcon = value;
      });
    });
  }

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
                          ? AppColors.backgroundSubtle
                          : AppColors.buttonDefault,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      isOn
                          ? Border.all(color: AppColors.themeNormal, width: 1)
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
                      isOn ? AppColors.themeNormal : AppColors.labelDefault,
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
                          ? AppColors.backgroundSubtle
                          : AppColors.buttonDefault,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      isOn
                          ? Border.all(color: AppColors.themeNormal, width: 1)
                          : null,
                ),
                child: IconButton(
                  icon: SvgPicture.asset(
                    'assets/images/icon/Icon_Flash.svg',
                    width: 32,
                    height: 32,
                    colorFilter: ColorFilter.mode(
                      isOn ? AppColors.themeNormal : AppColors.labelDefault,
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

        BlocBuilder<MetronomeBloc, MetronomeState>(
          builder: (context, state) {
            final isOn = state.reserveBeat;
            return Expanded(
              child: Container(
                height: 50,
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color:
                      isOn
                          ? AppColors.backgroundSubtle
                          : AppColors.buttonDefault,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      isOn
                          ? Border.all(color: AppColors.themeNormal, width: 1)
                          : null,
                ),
                child: IconButton(
                  icon: SvgPicture.asset(
                    'assets/images/icon/reserve_beat_icon.svg',
                    width: 32,
                    height: 32,
                    colorFilter: ColorFilter.mode(
                      isOn ? AppColors.themeNormal : AppColors.labelDefault,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: () async {
                    context.read<MetronomeBloc>().add(ToggleReserveBeat());
                  },
                ),
              ),
            );
          },
        ),

        const SizedBox(width: 8),

        // 소리 변경 토글
        Container(
          width: 70,
          height: 50,
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color:
                _isSoundMenuOpen
                    ? AppColors.backgroundSubtle
                    : AppColors.buttonDefault,
            borderRadius: BorderRadius.circular(12),
            border:
                _isSoundMenuOpen
                    ? Border.all(color: AppColors.themeNormal, width: 1)
                    : null,
          ),
          child: PopupMenuButton<Sound>(
            color: AppColors.backgroundElevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            icon: Text(
              context
                  .select((MetronomeBloc bloc) => bloc.state.currentSound)
                  .label,
              style: AppTextStyles.bodyR.copyWith(
                color:
                    _isSoundMenuOpen
                        ? AppColors.themeNormal
                        : AppColors.labelDefault,
              ),
            ),
            onCanceled: () {
              setState(() => _isSoundMenuOpen = false);
            },
            onSelected: (value) {
              setState(() => _isSoundMenuOpen = false);
              context.read<MetronomeBloc>().add(ChangeSound(value));
            },
            itemBuilder: (ctx) {
              return Sound.values.map((sound) {
                return PopupMenuItem(
                  value: sound,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(sound.label, style: AppTextStyles.bodyR),
                );
              }).toList();
            },
            onOpened: () {
              setState(() => _isSoundMenuOpen = true);
            },
          ),
        ),

        SizedBox(width: 8),

        Column(
          children: [
            if (!showNewMinimumIcon) WigglingSvgIcon(),
            InkWell(
              onTap: () {
                Storage().setFirstMinimumCheck();
                context.read<MetronomeBloc>().add(const ToggleMinimum());
                showNewMinimumIcon = true;
                setState(() {});
              },
              child: Container(
                width: 60,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.backgroundMute,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: BlocBuilder<MetronomeBloc, MetronomeState>(
                  builder: (context, state) {
                    return Center(
                      child: Icon(
                        context.read<MetronomeBloc>().state.minimum
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 36,
                        color: AppColors.labelTertiary,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
