import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hanbae/data/sound_manager.dart';
import 'package:hanbae/data/custom_jangdan_data.dart';
import 'package:hanbae/data/basic_jangdan_data.dart';
import 'package:hanbae/theme/colors.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final _soundManager = SoundManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              Image.asset("assets/images/banner/SurveyBannerTest.png"),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "내가 저장한 장단",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDefault
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(minimumSize: Size(0, 40)),
                        child: Text(
                          "더보기",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

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
                                  // 리스트 아이템이 2개 이상일 때 '더보기' 나타남
                                  return Container(
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
                                  );
                                } else {
                                  final item = customJangdanList[index];
                                  return Container(
                                    width: 156,
                                    height: 84,
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundSheet,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(16),
                                      ),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            item.title,
                                            style: TextStyle(
                                              fontSize: 17,
                                              color: AppColors.textDefault,
                                            ),
                                          ),
                                          Text(
                                            item.janganType,
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: AppColors.textTertiary,
                                            ),
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
                  Row(
                    children: [
                      Text(
                        "바로 연습하기",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDefault
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: basicJangdanList.length,
                    separatorBuilder: (context, index) => SizedBox(height: 8),
                    itemBuilder: (content, index) {
                      final item = basicJangdanList[index];
                      return Container(
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
                                          "assets/images/logos/Jinyang.svg",
                                          colorFilter: ColorFilter.mode(
                                            AppColors.jangdanLogoPrimary,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(width: 20),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(fontSize: 20,
                                      color: AppColors.textDefault),
                                    ),
                                    Text(
                                      item.bakType,
                                      style: TextStyle(fontSize: 15,
                                      color: AppColors.textQuaternary),
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
                      );
                    },
                  ),
                ],
              ),
            
            SizedBox(height: 80,)
            ],
          ),
        ),
      ),
    );
  }
}
