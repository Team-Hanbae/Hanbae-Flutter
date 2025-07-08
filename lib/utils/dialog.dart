import 'package:flutter/material.dart';
import 'package:hanbae/theme/colors.dart';
import 'package:lottie/lottie.dart';

class CommonDialog {
  firstShowDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.backgroundCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: SizedBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),

                // 제목
                Padding(
                  padding: const EdgeInsets.only(
                    left: 30,
                    right: 30,
                    bottom: 30,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '새로운 기능!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        // 선의 두께를 height로 조절
                        height: 1.0,
                        decoration: const BoxDecoration(
                          // 선형 그라데이션 적용
                          gradient: LinearGradient(
                            // 그라데이션 색상 설정
                            colors: [
                              Colors.transparent,
                              AppColors.textBPMDefault,
                              AppColors.textBPMDefault,
                              AppColors.textBPMDefault, // 중앙의 밝은 색
                              Colors.transparent,
                            ],
                            // 그라데이션의 시작점과 끝점 설정 (가로 방향)
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Lottie.asset('assets/lotties/fold.json'),

                      // 중앙 아이콘
                      // Center(
                      //   child: Container(
                      //     width: 80,
                      //     height: 80,
                      //     decoration: BoxDecoration(
                      //       color: Colors.grey[700],
                      //       borderRadius: BorderRadius.circular(12),
                      //     ),
                      //     child: Center(
                      //       child: Container(
                      //         width: 60,
                      //         height: 60,
                      //         decoration: BoxDecoration(
                      //           color: Colors.orange,
                      //           borderRadius: BorderRadius.circular(8),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(height: 24),

                      // 설명 텍스트
                      const Text(
                        '이제 화면을 더 크게 쓸 수 있어요.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.43,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // 확인 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '확인',
                              style: TextStyle(
                                fontSize: 17,
                                color: AppColors.textDefault,
                              ),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
