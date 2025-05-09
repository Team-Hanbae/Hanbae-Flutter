import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanbae/bloc/metronome/metronome_bloc.dart';
import 'package:hanbae/model/jangdan_type.dart';
import 'package:hanbae/presentation/custom_jangdan/custom_jangdan_create_screen.dart';
import 'package:hanbae/theme/colors.dart';
import 'package:hanbae/theme/text_styles.dart';
import 'package:intl/intl.dart';
import '../../bloc/jangdan/jangdan_bloc.dart';
import 'package:hanbae/presentation/metronome/metronome_screen.dart';

class CustomJangdanListScreen extends StatelessWidget {
  CustomJangdanListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<JangdanBloc>().add(LoadJangdan());

    return Scaffold(
      backgroundColor: AppColors.backgroundDefault,
      appBar: AppBar(
        toolbarHeight: 44.0,
        title: Text('내가 저장한 장단', style: AppTextStyles.bodyR.copyWith(color: AppColors.textSecondary)),
        centerTitle: true,
        backgroundColor: AppColors.backgroundNavigationbar,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CustomJangdanCreateScreen()));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: BlocBuilder<JangdanBloc, JangdanState>(
        builder: (context, state) {
          if (state is JangdanInitial) {
            return Center(child: CircularProgressIndicator());
          } else if (state is JangdanLoaded) {
            final jangdans = state.jangdans;
            return Padding(
              padding: const EdgeInsets.only(top: 28),
              child: ListView.builder(
                itemCount: jangdans.isEmpty ? 1 : jangdans.length,
                itemBuilder: (context, index) {
                if (jangdans.isEmpty) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CustomJangdanCreateScreen()),
                      );
                    },
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      title: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundCard,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '아직 저장한 장단이 없어요',
                                  style: AppTextStyles.subheadlineR.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '장단 만들러 가기',
                                  style: AppTextStyles.title3R.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: AppColors.textTertiary,
                            ),
                          ],
                        ),
                      ),
                    ),
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
                          child: Icon(Icons.delete, color: Colors.white, size: 24),
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.backgroundCard,
                            shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      12,
                                    ),
                                  ),
                            title: Text('삭제 확인', style: TextStyle(color: AppColors.textDefault),),
                            content: Text('정말 이 장단을 삭제할까요?', style: TextStyle(color: AppColors.textSecondary),),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text('취소', style: TextStyle(color: AppColors.textSecondary),)
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: Text('삭제', style: TextStyle(color: Colors.orangeAccent),),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (_) {
                        context.read<JangdanBloc>().add(DeleteJangdan(jangdan.name));
                      },
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        title: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundCard,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.7),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          jangdan.jangdanType.label,
                                          style: AppTextStyles.subheadlineR.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          jangdan.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.title3R.copyWith(
                                            color: AppColors.textDefault,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    DateFormat('yyyy.MM.dd.').format(jangdan.createdAt),
                                    style: AppTextStyles.subheadlineR.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        onTap: () {
                          context.read<MetronomeBloc>().add(SelectJangdan(jangdan));
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MetronomeScreen(
                                jangdan: jangdan,
                                appBarMode: AppBarMode.custom,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (index == jangdans.length - 1) const SizedBox(height: 32), // Add space after the last item
                  ],
                );
              },
              ),
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
              child: Text('알 수 없는 상태', style: TextStyle(color: Colors.grey)),
            );
          }
        },
      ),
    );
  }
}
