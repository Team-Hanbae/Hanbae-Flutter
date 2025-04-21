import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hanbae/bloc/metronome/metronome_bloc.dart';
import 'package:hanbae/bloc/jangdan/jangdan_bloc.dart';
import 'package:hanbae/data/basic_jangdan_data.dart';
import 'package:hanbae/model/jangdan.dart';
import 'package:hanbae/presentation/custom_jangdan/custom_jangdan_list_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hanbae/presentation/metronome/metronome_screen.dart';
import 'package:hanbae/theme/colors.dart';
import 'package:hanbae/theme/text_styles.dart';
import '../../model/jangdan_type.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<JangdanBloc>().state;
    final customJangdanList =
        state is JangdanLoaded ? state.jangdans : <Jangdan>[];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDefault,
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Image.asset("assets/images/AppLogo.png"),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final Uri url = Uri.parse(
                    'https://forms.gle/aB7Rks3KDA8NP9yM7',
                  );
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset("assets/images/banner/TestBanner.png"),
                ),
              ),

              const SizedBox(height: 24),

              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "내가 저장한 장단",
                          style: AppTextStyles.title2B.copyWith(
                            color: AppColors.textDefault,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomJangdanListScreen(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            minimumSize: Size(40, 40),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            "더보기",
                            style: AppTextStyles.calloutR.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    height: 84,
                    child:
                        customJangdanList.isEmpty
                            ? Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundSheet,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(16),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "저장한 장단이 없어요",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textQuaternary,
                                  ),
                                ),
                              ),
                            )
                            : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount:
                                  customJangdanList.length >= 2
                                      ? customJangdanList.length + 1
                                      : customJangdanList.length,
                              separatorBuilder:
                                  (context, index) => SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                if (customJangdanList.length >= 2 &&
                                    index == customJangdanList.length) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  CustomJangdanListScreen(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 156,
                                      height: 84,
                                      decoration: BoxDecoration(
                                        color: AppColors.backgroundSheet,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(16),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "더보기",
                                          style: TextStyle(
                                            fontSize: 17,
                                            color: AppColors.textTertiary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  final item = customJangdanList[index];
                                  return InkWell(
                                    onTap: () {
                                      context.read<MetronomeBloc>().add(
                                        SelectJangdan(item),
                                      );
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => MetronomeScreen(
                                                jangdan: item,
                                                appBarMode: AppBarMode.custom,
                                              ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 156,
                                      height: 84,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                        color: AppColors.backgroundSheet,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(16),
                                        ),
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Positioned.fill(
                                            child: OverflowBox(
                                              maxWidth: double.infinity,
                                              maxHeight: double.infinity,
                                              child: Transform.translate(
                                                offset: Offset(0, 110),
                                                child: Container(
                                                  width: 300,
                                                  height: 300,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: RadialGradient(
                                                      radius: 1.0,
                                                      center: Alignment.center,
                                                      colors: [
                                                        AppColors.bakBarActiveTop,
                                                        AppColors.backgroundCard.withAlpha(0),
                                                      ],
                                                      stops: [0, 0.5],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                item.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  color: AppColors.textDefault,
                                                ),
                                              ),
                                              Text(
                                                item.jangdanType.label,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: AppColors.textTertiary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                  ),
                ],
              ), //내가 저장한 장단 끝

              SizedBox(height: 32),

              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: SizedBox(
                      height: 40,
                      child: Row(
                        children: [
                          Text(
                            "바로 연습하기",
                            style: AppTextStyles.title2B.copyWith(
                              color: AppColors.textDefault,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: JangdanType.values.length,
                    separatorBuilder: (context, index) => SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final jangdan = JangdanType.values[index];
                      final selectedJangdan = basicJangdanData[jangdan.label]!;
                      return InkWell(
                        onTap: () {
                          context.read<MetronomeBloc>().add(
                            SelectJangdan(selectedJangdan),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => MetronomeScreen(
                                    jangdan: basicJangdanData[jangdan.label]!,
                                  ),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundSheet,
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.jangdanLogoBackground,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                    child: SizedBox(
                                      width: 64,
                                      height: 64,
                                      child: Center(
                                        child: SizedBox(
                                          width: 36,
                                          height: 36,
                                          child: SvgPicture.asset(
                                            "assets/${jangdan.logoAssetPath}",
                                            colorFilter: ColorFilter.mode(
                                              AppColors.jangdanLogoPrimary,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 20),

                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        jangdan.label,
                                        style: AppTextStyles.title3Sb.copyWith(
                                          color: AppColors.textDefault,
                                        ),
                                      ),
                                      Text(
                                        jangdan.bakInformation,
                                        style: AppTextStyles.subheadlineR
                                            .copyWith(
                                              color: AppColors.textQuaternary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 32,
                                color: AppColors.textTertiary,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
