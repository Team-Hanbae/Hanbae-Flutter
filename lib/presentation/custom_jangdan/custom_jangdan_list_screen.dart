import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanbae/theme/colors.dart';
import 'package:hanbae/theme/text_styles.dart';
import '../../bloc/jangdan/jangdan_bloc.dart';

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
                    print('+ 버튼 클릭됨');
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                    minimumSize: Size(40, 40),
                  ),
                  onPressed: () {
                    print('TextButton 클릭됨!');
                  },
                  child: Text('편집'),
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
            if (jangdans.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
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
                          SizedBox(width: 12),
                          Icon(
                            Icons.chevron_right,
                            color: AppColors.textTertiary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              itemCount: jangdans.length,
              itemBuilder: (context, index) {
                final jangdan = jangdans[index];
                return ListTile(
                  title: Text(
                    jangdan.name,
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    print('${jangdan.name} tapped');
                  },
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
              child: Text('알 수 없는 상태', style: TextStyle(color: Colors.grey)),
            );
          }
        },
      ),
    );
  }
}
