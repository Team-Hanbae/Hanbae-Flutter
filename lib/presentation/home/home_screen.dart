import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hanbae/bloc/metronome/metronome_bloc.dart';
import 'package:hanbae/bloc/jangdan/jangdan_bloc.dart';
import 'package:hanbae/data/basic_jangdan_data.dart';
import 'package:hanbae/model/jangdan.dart';
import 'package:hanbae/model/jangdan_category.dart';
import 'package:hanbae/presentation/custom_jangdan/custom_jangdan_create_screen.dart';
import 'package:hanbae/presentation/home/metronome_jangdan_list_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hanbae/presentation/metronome/metronome_screen.dart';
import 'package:hanbae/theme/colors.dart';
import 'package:hanbae/theme/text_styles.dart';
import '../../model/jangdan_type.dart';
import 'package:hanbae/utils/date_format.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<JangdanBloc>().state;
    final selectedCategory =
        state is JangdanLoaded
            ? state.selectedCategory
            : JangdanCategory.minsokak;
    final List<Jangdan?> jangdanList =
        state is JangdanLoaded ? selectedCategory.list ?? state.jangdans : [];
    final categories = JangdanCategory.values;
    final isCustomCategory = selectedCategory == JangdanCategory.custom;

    final List<Jangdan> recentPlayedJangdanList =
        state is JangdanLoaded ? state.recentJangdans : [];

    final bannerList = [
      {
        "image": "assets/images/banner/JeongakBanner.png",
        "link": "https://forms.gle/BxXn9vp7qWVQ6eoQA",
      },
      {
        "image": "assets/images/banner/SurveyBanner.png",
        "link": "https://forms.gle/pKarubn5MPXkudgw6",
      },
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalPadding = 16.0;
    final imageWidth = screenWidth - (horizontalPadding * 2);
    final bannerHeight = imageWidth / 3;

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
      backgroundColor: AppColors.backgroundDefault,
      body: SingleChildScrollView(
        child: Column(
          children: [
            CarouselSlider(
              items:
                  bannerList.map((item) {
                    final imagePath = item["image"]!;
                    final link = item["link"]!;
                    return Builder(
                      builder: (BuildContext context) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GestureDetector(
                            onTap: () async {
                              final Uri url = Uri.parse(link);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(
                                  url,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(imagePath),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
              options: CarouselOptions(
                height: bannerHeight,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 5),
                viewportFraction: 1.0,
              ),
            ),

            const SizedBox(height: 24),

            // 최근 연습
            if (recentPlayedJangdanList.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        "최근 연습",
                        style: AppTextStyles.title2B.copyWith(
                          color: AppColors.labelPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      spacing: 8,
                      children: List.generate(3, (index) {
                        if (index >= recentPlayedJangdanList.length) {
                          return const Expanded(child: SizedBox());
                        }

                        final jangdan = recentPlayedJangdanList[index];
                        final isCustomJangdan =
                            jangdan.name != jangdan.jangdanType.label;

                        return Expanded(
                          child: InkWell(
                            onTap: () {
                              context.read<MetronomeBloc>().add(
                                SelectJangdan(jangdan),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => MetronomeScreen(
                                        jangdan: jangdan,
                                        appBarMode: AppBarMode.custom,
                                      ),
                                ),
                              );
                            },
                            child: Container(
                              height: 100,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundMute,
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
                                                AppColors.bakBarTop,
                                                AppColors.neutral12.withAlpha(
                                                  0,
                                                ),
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
                                    spacing: isCustomJangdan ? 4 : 8,
                                    children: [
                                      isCustomJangdan
                                          ? Text(
                                            jangdan.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.calloutSb
                                                .copyWith(
                                                  color: AppColors.labelDefault,
                                                ),
                                          )
                                          : SizedBox(
                                            width: 36,
                                            height: 36,
                                            child: SvgPicture.asset(
                                              "assets/${jangdan.jangdanType.logoAssetPath}",
                                              colorFilter: ColorFilter.mode(
                                                AppColors.orange8,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                          ),
                                      Text(
                                        jangdan.jangdanType.label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            isCustomJangdan
                                                ? AppTextStyles.subheadlineR
                                                    .copyWith(
                                                      color:
                                                          AppColors
                                                              .labelSecondary,
                                                    )
                                                : AppTextStyles.subheadlineSb
                                                    .copyWith(
                                                      color:
                                                          AppColors
                                                              .labelDefault,
                                                    ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Container(
                width: double.infinity,
                height: 10,
                color: AppColors.backgroundDark,
              ),
            ],

            //내가 저장한 장단 끝
            const SizedBox(height: 24),

            // 장단 카테고리
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MetronomeJangdanListScreen(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 8,
                          ),
                          child: Text(
                            "전체 장단",
                            style: AppTextStyles.title2B.copyWith(
                              color: AppColors.labelPrimary,
                            ),
                          ),
                        ),

                        Icon(
                          Icons.chevron_right_rounded,
                          size: 32,
                          color: AppColors.labelDefault,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 12),

                // 카테고리 Segmented Control
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(categories.length, (index) {
                        final category = categories[index];
                        final isSelected = category == selectedCategory;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: () {
                              context.read<JangdanBloc>().add(
                                ChangeJangdanCategory(category),
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? AppColors.neutral1
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? Colors.transparent
                                          : AppColors.labelAssistive,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                category.label,
                                style:
                                    isSelected
                                        ? AppTextStyles.calloutSb.copyWith(
                                          color: AppColors.labelInverse,
                                        )
                                        : AppTextStyles.calloutR.copyWith(
                                          color: AppColors.labelSecondary,
                                        ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),

            // 장단 리스트
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child:
                  isCustomCategory
                      // 커스텀 장단 리스트
                      ? jangdanList.isEmpty
                          ? Column(
                            children: [
                              SizedBox(height: 10),

                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 44,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundMute,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "아직 저장한 장단이 없어요.\n원하는 강세와 빠르기로 장단을 저장해보세요!",
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.calloutR.copyWith(
                                        color: AppColors.labelDefault,
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    FilledButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const CustomJangdanCreateScreen(),
                                          ),
                                        );
                                      },
                                      style: FilledButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 10,
                                        ),
                                        backgroundColor: AppColors.brandHeavy,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        "장단 만들러 가기",
                                        style: AppTextStyles.bodySb.copyWith(
                                          color: AppColors.labelPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 100),
                            ],
                          )
                          : ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            itemCount: jangdanList.length,
                            separatorBuilder:
                                (context, index) => SizedBox(height: 0),
                            itemBuilder: (context, index) {
                              final jangdan = jangdanList[index]!;
                              return InkWell(
                                onTap: () {
                                  context.read<MetronomeBloc>().add(
                                    SelectJangdan(jangdan),
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => MetronomeScreen(
                                            jangdan: jangdan,
                                            appBarMode: AppBarMode.custom,
                                          ),
                                    ),
                                  );
                                },
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(16),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: AppColors.orange13,
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
                                                    "assets/${jangdan.jangdanType.logoAssetPath}",
                                                    colorFilter:
                                                        ColorFilter.mode(
                                                          AppColors.orange8,
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
                                                jangdan.name,
                                                style: AppTextStyles.title3Sb
                                                    .copyWith(
                                                      color:
                                                          AppColors
                                                              .labelDefault,
                                                    ),
                                              ),

                                              const SizedBox(height: 4),

                                              Text(
                                                jangdan.jangdanType.label,
                                                style: AppTextStyles
                                                    .subheadlineR
                                                    .copyWith(
                                                      color:
                                                          AppColors
                                                              .labelSecondary,
                                                    ),
                                              ),
                                            ],
                                          ),

                                          Spacer(),

                                          Text(
                                            formatDateShort(jangdan.createdAt),
                                            style: AppTextStyles.subheadlineR
                                                .copyWith(
                                                  color:
                                                      AppColors.labelTertiary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 1,
                                      width: double.infinity,
                                      color: AppColors.neutral11,
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                      // BuiltIn 장단 리스트
                      : ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: jangdanList.length,
                        separatorBuilder:
                            (context, index) => SizedBox(height: 0),
                        itemBuilder: (context, index) {
                          final jangdan = jangdanList[index]!;
                          final selectedJangdan =
                              basicJangdanData[jangdan.jangdanType.label]!;
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
                                        jangdan:
                                            basicJangdanData[jangdan
                                                .jangdanType
                                                .label]!,
                                      ),
                                ),
                              );
                            },
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(16),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.orange13,
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
                                                "assets/${jangdan.jangdanType.logoAssetPath}",
                                                colorFilter: ColorFilter.mode(
                                                  AppColors.orange8,
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
                                            jangdan.jangdanType.label,
                                            style: AppTextStyles.bodySb
                                                .copyWith(
                                                  color: AppColors.labelDefault,
                                                ),
                                          ),

                                          const SizedBox(height: 4),

                                          Text(
                                            jangdan.jangdanType.bakInformation,
                                            style: AppTextStyles.subheadlineR
                                                .copyWith(
                                                  color:
                                                      AppColors.labelTertiary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 1,
                                  width: double.infinity,
                                  color: AppColors.neutral11,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
