import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hanbae/bloc/jangdan/jangdan_bloc.dart';
import 'package:hanbae/bloc/metronome/metronome_bloc.dart';
import 'package:hanbae/data/basic_jangdan_data.dart';
import 'package:hanbae/model/jangdan_type.dart';
import 'package:hanbae/presentation/custom_jangdan/custom_jangdan_create_screen.dart';
import 'package:hanbae/presentation/metronome/metronome_screen.dart';
import 'package:hanbae/theme/colors.dart';
import 'package:hanbae/theme/text_styles.dart';
import 'package:hanbae/utils/date_format.dart';

class EditingCubit extends Cubit<bool> {
  EditingCubit() : super(false);

  void toggle() => emit(!state);
  void on() => emit(true);
  void off() => emit(false);
}

class MetronomeJangdanListScreen extends StatelessWidget {
  const MetronomeJangdanListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<JangdanBloc>().add(LoadJangdan());

    final isEditing = context.watch<EditingCubit>().state;

    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);

          return Scaffold(
            backgroundColor: AppColors.backgroundDefault,
            appBar: AppBar(
              toolbarHeight: 44.0,
              title: Text(
                '전체 장단',
                style: AppTextStyles.bodyR.copyWith(
                  color: AppColors.labelDefault,
                ),
              ),
              centerTitle: true,
              backgroundColor: AppColors.backgroundMute,
              actions: [
                AnimatedBuilder(
                  animation: tabController,
                  builder: (context, _) {
                    if (tabController.index == 0) {
                      context.read<EditingCubit>().off();
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: BlocBuilder<EditingCubit, bool>(
                        builder: (context, isEditing) {
                          return Row(
                            children: [
                              if (!isEditing)
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                CustomJangdanCreateScreen(),
                                      ),
                                    );
                                  },
                                ),
                              TextButton(
                                child: Text(
                                  isEditing ? "완료" : "편집",
                                  style: AppTextStyles.bodyR.copyWith(
                                    color: AppColors.labelPrimary,
                                  ),
                                ),
                                onPressed: () {
                                  context.read<EditingCubit>().toggle();
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
              bottom: TabBar(
                controller: tabController,
                labelStyle: AppTextStyles.bodySb,
                unselectedLabelStyle: AppTextStyles.bodyR,
                labelColor: AppColors.labelDefault,
                unselectedLabelColor: AppColors.labelDefault,
                indicatorColor: AppColors.neutral4,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 2,
                tabs: const [Tab(text: "기본 장단"), Tab(text: "저장한 장단")],
              ),
            ),
            body: TabBarView(
              controller: tabController,
              children: [
                ListView.separated(
                  padding: EdgeInsets.only(
                    top: 8,
                    left: 16,
                    right: 16,
                    bottom: 100,
                  ),
                  scrollDirection: Axis.vertical,
                  itemCount: JangdanType.values.length,
                  separatorBuilder: (context, index) => SizedBox(height: 0),
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
                                          "assets/${jangdan.logoAssetPath}",
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      jangdan.label,
                                      style: AppTextStyles.bodySb.copyWith(
                                        color: AppColors.labelDefault,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      jangdan.bakInformation,
                                      style: AppTextStyles.subheadlineR
                                          .copyWith(
                                            color: AppColors.labelTertiary,
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

                BlocBuilder<JangdanBloc, JangdanState>(
                  builder: (context, state) {
                    if (state is JangdanInitial) {
                      return Center(child: CircularProgressIndicator());
                    } else if (state is JangdanLoaded) {
                      final jangdans = state.jangdans;
                      return ListView.builder(
                        padding: EdgeInsets.only(
                          left: 16,
                          top: 8,
                          right: 16,
                          bottom: 100,
                        ),
                        itemCount: jangdans.isEmpty ? 1 : jangdans.length,
                        itemBuilder: (context, index) {
                          if (jangdans.isEmpty) {
                            return Column(
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
                            );
                          }

                          final jangdan = jangdans[index];
                          return Column(
                            children: [
                              Dismissible(
                                key: ValueKey(jangdan.name),
                                direction: DismissDirection.endToStart,

                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: EdgeInsets.all(12),
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  return await showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          backgroundColor:
                                              AppColors.backgroundElevated,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          title: Text(
                                            '삭제 확인',
                                            style: TextStyle(
                                              color: AppColors.labelPrimary,
                                            ),
                                          ),
                                          content: Text(
                                            '정말 이 장단을 삭제할까요?',
                                            style: TextStyle(
                                              color: AppColors.labelDefault,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    context,
                                                  ).pop(false),
                                              child: Text(
                                                '취소',
                                                style: TextStyle(
                                                  color:
                                                      AppColors.labelSecondary,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    context,
                                                  ).pop(true),
                                              child: Text(
                                                '삭제',
                                                style: TextStyle(
                                                  color: AppColors.brandNormal,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                  );
                                },
                                onDismissed: (_) {
                                  context.read<JangdanBloc>().add(
                                    DeleteJangdan(jangdan.name),
                                  );
                                },
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 0,
                                    vertical: 0,
                                  ),
                                  minVerticalPadding: 0,
                                  title: Stack(
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
                                            Expanded(
                                              flex: 300,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    jangdan.name,
                                                    style: AppTextStyles
                                                        .bodySb
                                                        .copyWith(
                                                          color:
                                                              AppColors
                                                                  .labelDefault,
                                                        ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),

                                                  const SizedBox(height: 4),

                                                  Text(
                                                    jangdan.jangdanType.label,
                                                    style: AppTextStyles
                                                        .subheadlineR
                                                        .copyWith(
                                                          color:
                                                              AppColors
                                                                  .labelTertiary,
                                                        ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ],
                                              ),
                                            ),

                                            Spacer(),

                                            Text(
                                              formatDateShort(
                                                jangdan.createdAt,
                                              ),
                                              style: AppTextStyles.subheadlineR
                                                  .copyWith(
                                                    color:
                                                        AppColors.labelTertiary,
                                                  ),
                                            ),

                                            if (isEditing)
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: 12,
                                                ),
                                                child: InkWell(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    padding: EdgeInsets.all(12),
                                                    child: Icon(
                                                      Icons.delete,
                                                      color: Colors.white,
                                                      size: 24,
                                                    ),
                                                  ),
                                                  onTap: () async {
                                                    return await showDialog(
                                                      context: context,
                                                      builder:
                                                          (
                                                            context,
                                                          ) => AlertDialog(
                                                            backgroundColor:
                                                                AppColors
                                                                    .backgroundElevated,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                            ),
                                                            title: Text(
                                                              '삭제 확인',
                                                              style: TextStyle(
                                                                color:
                                                                    AppColors
                                                                        .labelPrimary,
                                                              ),
                                                            ),
                                                            content: Text(
                                                              '정말 이 장단을 삭제할까요?',
                                                              style: TextStyle(
                                                                color:
                                                                    AppColors
                                                                        .labelDefault,
                                                              ),
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed:
                                                                    () => Navigator.of(
                                                                      context,
                                                                    ).pop(
                                                                      false,
                                                                    ),
                                                                child: Text(
                                                                  '취소',
                                                                  style: TextStyle(
                                                                    color:
                                                                        AppColors
                                                                            .labelSecondary,
                                                                  ),
                                                                ),
                                                              ),
                                                              TextButton(
                                                                onPressed:
                                                                    () => {
                                                                      Navigator.of(
                                                                        context,
                                                                      ).pop(
                                                                        true,
                                                                      ),
                                                                      context
                                                                          .read<
                                                                            JangdanBloc
                                                                          >()
                                                                          .add(
                                                                            DeleteJangdan(
                                                                              jangdan.name,
                                                                            ),
                                                                          ),
                                                                    },
                                                                child: Text(
                                                                  '삭제',
                                                                  style: TextStyle(
                                                                    color:
                                                                        AppColors
                                                                            .brandNormal,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                    );
                                                  },
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
                                  onTap: () {
                                    if (isEditing) return;

                                    context.read<MetronomeBloc>().add(
                                      SelectJangdan(jangdan),
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => MetronomeScreen(
                                              jangdan: jangdan,
                                              appBarMode: AppBarMode.custom,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    } else if (state is JangdanError) {
                      return Center(
                        child: Text(
                          '에러 발생: ${state.message}',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    } else {
                      return Center(
                        child: Text(
                          '알 수 없는 상태',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
