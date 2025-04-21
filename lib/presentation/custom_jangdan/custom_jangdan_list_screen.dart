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
      backgroundColor: Color(0xFF000000),
      appBar: AppBar(
        title: Text('내가 저장한 장단', style: TextStyle(fontSize: 17)),
        centerTitle: true,
        backgroundColor: Color(0xFF1F1F1F),
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
                // TextButton(
                //   style: TextButton.styleFrom(
                //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                //     padding: EdgeInsets.zero,
                //     minimumSize: Size(40, 40),
                //   ),
                //   onPressed: () {
                //     print('TextButton 클릭됨!');
                //   },
                //   child: Text(
                //     '편집',
                //     style: AppTextStyles.bodyR.copyWith(
                //       color: AppColors.textDefault,
                //     ),
                //   ),
                // ),
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
              padding: const EdgeInsets.only(top: 32),
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
                return Dismissible(
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
                        title: Text('삭제 확인'),
                        content: Text('정말 이 장단을 삭제할까요?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('취소'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text('삭제'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) {
                    context.read<JangdanBloc>().add(DeleteJangdan(jangdan.name));
                  },
                  child: ListTile(
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
