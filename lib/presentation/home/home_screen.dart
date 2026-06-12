import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hanbae/bloc/metronome/metronome_bloc.dart';
import 'package:hanbae/bloc/jangdan/jangdan_bloc.dart';
import 'package:hanbae/data/analytics_service.dart';
import 'package:hanbae/data/basic_jangdan_data.dart';
import 'package:hanbae/data/remote_config_service.dart';
import 'package:hanbae/model/jangdan.dart';
import 'package:hanbae/model/jangdan_category.dart';
import 'package:hanbae/model/home_promotion.dart';
import 'package:hanbae/model/saved_jangdan_item.dart';
import 'package:hanbae/presentation/custom_jangdan/custom_jangdan_create_screen.dart';
import 'package:hanbae/presentation/home/metronome_jangdan_list_screen.dart';
import 'package:hanbae/presentation/sequence/jangdan_sequence_create_screen.dart';
import 'package:hanbae/presentation/sequence/jangdan_sequence_onboarding_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hanbae/presentation/metronome/metronome_screen.dart';
import 'package:hanbae/theme/colors.dart';
import 'package:hanbae/theme/text_styles.dart';
import '../../model/jangdan_type.dart';
import 'package:hanbae/utils/date_format.dart';
import 'package:hanbae/utils/dialogs/christmas_dialog.dart';
import 'package:hanbae/utils/local_storage.dart';
import 'package:hanbae/presentation/common/ad_banner.dart';
import 'package:hanbae/utils/admob_ids.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<HomePromotionBanner> _remoteBanners = const [];
  List<HomeAdModal> _remoteAdModals = const [];
  final Set<String> _impressedRemoteBannerIds = {};
  final Set<String> _dismissedAdModalIds = {};
  bool _isAdModalShowing = false;

  //크리스마스 팝업
  @override
  void initState() {
    super.initState();
    _loadRemoteBanners();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final now = DateTime.now();
      final isChristmas = (now.month == 12 && now.day == 25);

      if (!isChristmas) return;

      final todayKey = DateTime.now().toIso8601String().split('T').first;
      final storage = Storage();

      final shouldShow = await storage.shouldShowChristmasPopup(todayKey);
      if (!mounted || !shouldShow) return;

      final result = await ChristmasDialog.show(context);
      if (result == null) return;

      await storage.setChristmasPopupDontShowToday(
        result.dontShowToday,
        todayKey,
      );
    });
  } // initState

  Future<void> _loadRemoteBanners() async {
    final promotions = await remoteConfigService.fetchHomePromotions();
    if (!mounted) return;
    setState(() {
      _remoteBanners = promotions.banners;
      _remoteAdModals = promotions.adModals;
      _impressedRemoteBannerIds.clear();
    });
    _trackRemoteBannerImpression(0);
    _showNextAdModalIfNeeded();
  }

  void _trackRemoteBannerImpression(int index) {
    if (index < 0 || index >= _remoteBanners.length) return;
    final banner = _remoteBanners[index];
    if (!_impressedRemoteBannerIds.add(banner.id)) return;
    analytics.homePromotionImpression(id: banner.id, promotionType: 'banner');
  }

  Future<void> _openMetronomeTutorial(BuildContext context) async {
    final jangdan = basicJangdanData["자진모리"];
    if (jangdan == null) return;
    context.read<MetronomeBloc>().add(SelectJangdan(jangdan));
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MetronomeScreen(
              jangdan: jangdan,
              appBarMode: AppBarMode.builtin,
              forceShowOnboarding: true,
            ),
      ),
    );
  }

  Future<void> _handleRemoteBannerTap(
    BuildContext context,
    HomePromotionBanner banner,
  ) async {
    analytics.homePromotionClick(id: banner.id, promotionType: 'banner');

    final linkUrl = banner.linkUrl;
    if (linkUrl != null) {
      await launchUrl(linkUrl, mode: LaunchMode.externalApplication);
      return;
    }

    if (banner.id == 'metronome_tutorial') {
      if (!context.mounted) return;
      await _openMetronomeTutorial(context);
    }
  }

  Future<void> _handleLocalBannerTap(
    BuildContext context,
    _LocalHomeBanner banner,
  ) async {
    final linkUrl = banner.linkUrl;
    if (linkUrl != null) {
      await launchUrl(linkUrl, mode: LaunchMode.externalApplication);
      return;
    }

    if (banner.action == _LocalHomeBannerAction.metronomeTutorial) {
      if (!context.mounted) return;
      await _openMetronomeTutorial(context);
    }
  }

  Future<void> _showNextAdModalIfNeeded() async {
    if (_isAdModalShowing || !mounted) return;

    for (final modal in _remoteAdModals) {
      if (_dismissedAdModalIds.contains(modal.id)) continue;
      if (await Storage().isHomeAdModalHidden(modal.id)) continue;
      if (!mounted || _isAdModalShowing) return;
      await _showAdModal(modal);
      return;
    }
  }

  Future<void> _showAdModal(HomeAdModal modal) async {
    _isAdModalShowing = true;
    analytics.homePromotionImpression(id: modal.id, promotionType: 'modal');

    final dontShowToday = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.dimmerStrong,
      builder:
          (dialogContext) => _HomeAdModalDialog(
            modal: modal,
            onImageTap: () => _handleAdModalImageTap(modal),
          ),
    );

    _dismissedAdModalIds.add(modal.id);
    if (dontShowToday == true) {
      await Storage().hideHomeAdModalToday(modal.id);
    }
    _isAdModalShowing = false;

    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showNextAdModalIfNeeded();
    });
  }

  Future<void> _handleAdModalImageTap(HomeAdModal modal) async {
    analytics.homePromotionClick(id: modal.id, promotionType: 'modal');
    final linkUrl = modal.linkUrl;
    if (linkUrl == null) return;
    await launchUrl(linkUrl, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<JangdanBloc>().state;

    if (state is! JangdanLoaded) {
      return SizedBox();
    }

    final selectedCategory = state.selectedCategory;
    final List<Jangdan?> jangdanList = selectedCategory.list ?? state.jangdans;
    final categories = JangdanCategory.values;
    final isCustomCategory = selectedCategory == JangdanCategory.custom;
    final savedItems = state.savedItems;

    final recentItems = state.recentItems;

    final localBannerList = [
      _LocalHomeBanner(
        imageAsset: "assets/images/banner/SurveyBanner.png",
        linkUrl: Uri.parse("https://forms.gle/pKarubn5MPXkudgw6"),
      ),
      const _LocalHomeBanner(
        imageAsset: "assets/images/banner/OnboardingBanner.png",
        action: _LocalHomeBannerAction.metronomeTutorial,
      ),
    ];
    final useRemoteBanners = _remoteBanners.isNotEmpty;

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
                  (useRemoteBanners ? _remoteBanners : localBannerList).map((
                    item,
                  ) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GestureDetector(
                            onTap: () async {
                              if (item is HomePromotionBanner) {
                                await _handleRemoteBannerTap(context, item);
                              } else if (item is _LocalHomeBanner) {
                                await _handleLocalBannerTap(context, item);
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child:
                                  item is HomePromotionBanner
                                      ? Image.network(
                                        item.imageUrl.toString(),
                                        width: imageWidth,
                                        height: bannerHeight,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const _BannerImagePlaceholder(),
                                      )
                                      : Image.asset(
                                        (item as _LocalHomeBanner).imageAsset,
                                        width: imageWidth,
                                        height: bannerHeight,
                                        fit: BoxFit.cover,
                                      ),
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
                onPageChanged: (index, reason) {
                  if (useRemoteBanners) {
                    _trackRemoteBannerImpression(index);
                  }
                },
              ),
            ),

            if (recentItems.isNotEmpty) ...[
              const SizedBox(height: 24),

              // 최근 연습
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
                      spacing: 4,
                      children: List.generate(3, (index) {
                        if (index >= recentItems.length) {
                          return const Expanded(child: SizedBox());
                        }

                        final item = recentItems[index];
                        final jangdan = item.jangdan;
                        final sequence = item.sequence;
                        final isSequence =
                            item.kind == SavedJangdanItemKind.sequence;
                        final playableSequence =
                            isSequence &&
                                    sequence != null &&
                                    sequence.items.isNotEmpty
                                ? sequence
                                : null;
                        final displayJangdan =
                            isSequence
                                ? playableSequence?.items.first.jangdan
                                : jangdan;
                        if (displayJangdan == null) {
                          return const Expanded(child: SizedBox());
                        }
                        final isCustomJangdan =
                            !isSequence &&
                            displayJangdan.name !=
                                displayJangdan.jangdanType.label;

                        return Expanded(
                          child: InkWell(
                            onTap: () {
                              if (isSequence) {
                                final selectedSequence = playableSequence;
                                if (selectedSequence == null) return;
                                context.read<MetronomeBloc>().add(
                                  SelectSequence(selectedSequence),
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => MetronomeScreen(
                                          jangdan:
                                              selectedSequence
                                                  .items
                                                  .first
                                                  .jangdan,
                                          sequence: selectedSequence,
                                          appBarMode: AppBarMode.sequence,
                                        ),
                                  ),
                                );
                                return;
                              }

                              context.read<MetronomeBloc>().add(
                                SelectJangdan(displayJangdan),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => MetronomeScreen(
                                        jangdan: displayJangdan,
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
                                            item.name,
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
                                              isSequence
                                                  ? 'assets/images/logos/Sequence.svg'
                                                  : "assets/${displayJangdan.jangdanType.logoAssetPath}",
                                              colorFilter: ColorFilter.mode(
                                                AppColors.orange8,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                          ),
                                      Text(
                                        isSequence
                                            ? item.name
                                            : displayJangdan.jangdanType.label,
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
            ],

            //최근 연습 끝
            _SequenceCreateBanner(),

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

                // 카테고리 Segment Control
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(width: 16),
                      ...List.generate(categories.length, (index) {
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
                      SizedBox(width: 16),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),

            // 장단 리스트
            Container(
              constraints: const BoxConstraints(minHeight: 400),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child:
                  isCustomCategory
                      // 커스텀 장단 리스트
                      ? savedItems.isEmpty
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
                            itemCount: savedItems.length,
                            separatorBuilder:
                                (context, index) => SizedBox(height: 0),
                            itemBuilder: (context, index) {
                              final item = savedItems[index];
                              final jangdan = item.jangdan;
                              final sequence = item.sequence;
                              final isSequence =
                                  item.kind == SavedJangdanItemKind.sequence;
                              final playableSequence =
                                  isSequence &&
                                          sequence != null &&
                                          sequence.items.isNotEmpty
                                      ? sequence
                                      : null;
                              final displayJangdan =
                                  isSequence
                                      ? playableSequence?.items.first.jangdan
                                      : jangdan;
                              if (displayJangdan == null) {
                                return const SizedBox.shrink();
                              }
                              return InkWell(
                                onTap: () {
                                  if (isSequence) {
                                    final selectedSequence = playableSequence;
                                    if (selectedSequence == null) return;
                                    context.read<MetronomeBloc>().add(
                                      SelectSequence(selectedSequence),
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => MetronomeScreen(
                                              jangdan:
                                                  selectedSequence
                                                      .items
                                                      .first
                                                      .jangdan,
                                              sequence: selectedSequence,
                                              appBarMode: AppBarMode.sequence,
                                            ),
                                      ),
                                    );
                                    return;
                                  }

                                  context.read<MetronomeBloc>().add(
                                    SelectJangdan(displayJangdan),
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => MetronomeScreen(
                                            jangdan: displayJangdan,
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
                                              shape:
                                                  isSequence
                                                      ? BoxShape.circle
                                                      : BoxShape.rectangle,
                                              borderRadius:
                                                  isSequence
                                                      ? null
                                                      : BorderRadius.all(
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
                                                  child:
                                                      isSequence
                                                          ? SvgPicture.asset(
                                                            'assets/images/logos/Sequence.svg',
                                                            colorFilter:
                                                                const ColorFilter.mode(
                                                                  AppColors
                                                                      .orange8,
                                                                  BlendMode
                                                                      .srcIn,
                                                                ),
                                                          )
                                                          : SvgPicture.asset(
                                                            "assets/${displayJangdan.jangdanType.logoAssetPath}",
                                                            colorFilter:
                                                                ColorFilter.mode(
                                                                  AppColors
                                                                      .orange8,
                                                                  BlendMode
                                                                      .srcIn,
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
                                                item.name,
                                                style: AppTextStyles.bodySb
                                                    .copyWith(
                                                      color:
                                                          AppColors
                                                              .labelDefault,
                                                    ),
                                              ),

                                              const SizedBox(height: 4),

                                              Text(
                                                isSequence
                                                    ? ''
                                                    : displayJangdan
                                                        .jangdanType
                                                        .label,
                                                style: AppTextStyles
                                                    .subheadlineR
                                                    .copyWith(
                                                      color:
                                                          AppColors
                                                              .labelTertiary,
                                                    ),
                                              ),
                                            ],
                                          ),

                                          Spacer(),

                                          Text(
                                            formatDateShort(item.createdAt),
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
      bottomNavigationBar: SafeArea(
        top: false,
        child: FixedBannerAd(adUnitId: AdMobIds.bannerAdUnitId),
      ),
    );
  }
}

enum _LocalHomeBannerAction { metronomeTutorial }

class _LocalHomeBanner {
  final String imageAsset;
  final Uri? linkUrl;
  final _LocalHomeBannerAction? action;

  const _LocalHomeBanner({required this.imageAsset, this.linkUrl, this.action});
}

class _BannerImagePlaceholder extends StatelessWidget {
  const _BannerImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundMute,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.labelTertiary,
      ),
    );
  }
}

class _HomeAdModalDialog extends StatefulWidget {
  final HomeAdModal modal;
  final VoidCallback onImageTap;

  const _HomeAdModalDialog({required this.modal, required this.onImageTap});

  @override
  State<_HomeAdModalDialog> createState() => _HomeAdModalDialogState();
}

class _HomeAdModalDialogState extends State<_HomeAdModalDialog> {
  bool _dontShowToday = false;

  void _close() {
    Navigator.pop(context, _dontShowToday);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _close,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 320,
                          height: 44,
                          color: AppColors.backgroundDefault,
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.neutral8,
                                  borderRadius: BorderRadius.circular(500),
                                ),
                                child: Text(
                                  '광고',
                                  style: AppTextStyles.footnoteSb.copyWith(
                                    color: AppColors.labelPrimary,
                                    fontSize: 13,
                                    height: 18 / 13,
                                    letterSpacing: -0.08,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: _close,
                                icon: SvgPicture.asset(
                                  'assets/images/icon/x_mark.svg',
                                  width: 16,
                                  height: 16,
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onImageTap,
                          child: Image.network(
                            widget.modal.imageUrl.toString(),
                            width: 320,
                            fit: BoxFit.fitWidth,
                            errorBuilder:
                                (context, error, stackTrace) => const SizedBox(
                                  width: 320,
                                  height: 320,
                                  child: _BannerImagePlaceholder(),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      setState(() {
                        _dontShowToday = !_dontShowToday;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color:
                                  _dontShowToday
                                      ? AppColors.brandHeavy
                                      : Colors.transparent,
                              border: Border.all(
                                color:
                                    _dontShowToday
                                        ? AppColors.brandHeavy
                                        : AppColors.labelSecondary,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child:
                                _dontShowToday
                                    ? const Icon(
                                      Icons.check_rounded,
                                      color: AppColors.labelPrimary,
                                      size: 16,
                                    )
                                    : null,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '오늘 다시 보지 않기',
                            style: AppTextStyles.calloutR.copyWith(
                              color: AppColors.labelPrimary,
                              fontSize: 16,
                              height: 21 / 16,
                              letterSpacing: -0.31,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SequenceCreateBanner extends StatefulWidget {
  @override
  State<_SequenceCreateBanner> createState() => _SequenceCreateBannerState();
}

class _SequenceCreateBannerState extends State<_SequenceCreateBanner> {
  Timer? _debugOnboardingTimer;
  bool _debugOnboardingTriggered = false;

  @override
  void dispose() {
    _debugOnboardingTimer?.cancel();
    super.dispose();
  }

  Future<void> _openSequenceCreate(BuildContext context) async {
    analytics.sequenceEntryClick();
    final seen = await Storage().getSequenceOnboardingSeen();
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                seen
                    ? const JangdanSequenceCreateScreen()
                    : const JangdanSequenceOnboardingScreen(),
      ),
    );
  }

  void _openSequenceOnboarding(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const JangdanSequenceOnboardingScreen(),
      ),
    );
  }

  void _startDebugOnboardingTimer(BuildContext context) {
    if (!kDebugMode) return;
    _debugOnboardingTriggered = false;
    _debugOnboardingTimer?.cancel();
    _debugOnboardingTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      _debugOnboardingTriggered = true;
      _openSequenceOnboarding(context);
    });
  }

  void _cancelDebugOnboardingTimer() {
    _debugOnboardingTimer?.cancel();
    _debugOnboardingTimer = null;
  }

  void _handleTapUp(BuildContext context) {
    final skipTap = _debugOnboardingTriggered;
    _debugOnboardingTriggered = false;
    _cancelDebugOnboardingTimer();
    if (skipTap) return;
    _openSequenceCreate(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 10,
          color: AppColors.backgroundDark,
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(
            borderRadius: BorderRadius.circular(500),
            onTapDown: (_) => _startDebugOnboardingTimer(context),
            onTapCancel: _cancelDebugOnboardingTimer,
            onTapUp: (_) => _handleTapUp(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(500),
              child: SizedBox(
                height: 78,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/img_Sequence.png',
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      left: 27,
                      top: 14,
                      child: Row(
                        children: [
                          Text(
                            '장단 연속연습',
                            style: AppTextStyles.title2B.copyWith(
                              color: AppColors.labelPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF131313),
                              borderRadius: BorderRadius.circular(500),
                            ),
                            child: Text(
                              '새로운 기능!',
                              style: AppTextStyles.footnoteSb.copyWith(
                                color: AppColors.labelDefault,
                                fontSize: 13,
                                height: 18 / 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 28,
                      top: 44,
                      child: Text(
                        '서로 다른 장단을 이어서 연습해보세요!',
                        style: AppTextStyles.subheadlineR.copyWith(
                          color: AppColors.labelPrimary,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 17,
                      top: 19,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.labelPrimary.withAlpha(77),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.labelPrimary,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
