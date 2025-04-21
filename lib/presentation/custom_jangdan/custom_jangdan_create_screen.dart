import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanbae/bloc/metronome/metronome_bloc.dart';
import 'package:hanbae/data/basic_jangdan_data.dart';
import 'package:hanbae/model/jangdan_type.dart';
import 'package:hanbae/theme/colors.dart';
import 'package:hanbae/theme/text_styles.dart';
import 'package:hanbae/presentation/metronome/metronome_screen.dart';

class CustomJangdanCreateScreen extends StatelessWidget {
  const CustomJangdanCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내가 저장한 장단', style: TextStyle(fontSize: 17)),
        centerTitle: true,
        backgroundColor: Color(0xFF1F1F1F),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "만들 장단의\n종류를 선택해주세요.",
              style: AppTextStyles.title1R.copyWith(color: AppColors.textDefault),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: JangdanType.values.length,
                separatorBuilder: (_, __) => const Divider(
                  color: Color(0x99545456),
                  height: 1,
                  thickness: 0.4,
                ),
                itemBuilder: (context, index) {
                  final jangdan = JangdanType.values[index];
                  
                  return GestureDetector(
                    onTap: () {
                      final jangdanInstance = basicJangdanData[jangdan.label]!;
                      context.read<MetronomeBloc>().add(SelectJangdan(jangdanInstance));
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MetronomeScreen(
                            jangdan: jangdanInstance,
                            appBarMode: AppBarMode.create,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSheet,
                        borderRadius: BorderRadius.vertical(
                          top: index == 0 ? Radius.circular(16) : Radius.zero,
                          bottom: index == JangdanType.values.length - 1 ? Radius.circular(16) : Radius.zero,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            jangdan.label,
                            style: AppTextStyles.title3R.copyWith(
                              color: AppColors.textDefault,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textTertiary,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}