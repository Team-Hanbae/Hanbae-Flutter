import 'package:flutter/material.dart';
import 'package:hanbae/theme/colors.dart';
import 'package:hanbae/theme/text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ChristmasDialogAction {
  close,
  confirm,
}

class ChristmasDialogResult {
  const ChristmasDialogResult({
    required this.action,
    required this.dontShowToday,
  });

  final ChristmasDialogAction action;
  final bool dontShowToday;
}

class ChristmasDialog {
  /// 다이얼로그 종료 결과를 반환한다.
  /// - action: 어떤 버튼으로 닫았는지 (close / confirm)
  /// - dontShowToday: "오늘 다시 보지 않기" 체크 여부
  static Future<ChristmasDialogResult?> show(BuildContext context) {
    return showDialog<ChristmasDialogResult>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.dimmerStrong,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: _ChristmasPopupContent(
            onClose: (bool dontShowToday) => Navigator.of(dialogContext).pop(
              ChristmasDialogResult(
                action: ChristmasDialogAction.close,
                dontShowToday: dontShowToday,
              ),
            ),
            onConfirm: (bool dontShowToday) => Navigator.of(dialogContext).pop(
              ChristmasDialogResult(
                action: ChristmasDialogAction.confirm,
                dontShowToday: dontShowToday,
              ),
            ),
          ),
        );
      },
    ); // showDialog
  } // show
} // ChristmasDialog

class _ChristmasPopupContent extends StatefulWidget {
  const _ChristmasPopupContent({
    required this.onClose,
    required this.onConfirm,
  });

  final ValueChanged<bool> onClose;
  final ValueChanged<bool> onConfirm;

  @override
  State<_ChristmasPopupContent> createState() => _ChristmasPopupContentState();
} // _ChristmasPopupContent

class _ChristmasPopupContentState extends State<_ChristmasPopupContent> {
  bool _dontShowToday = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 카드(그라데이션 배경)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(23, 84, 64, 1),
                  Color.fromRGBO(18, 28, 38, 1),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // X 버튼
                Align(
                  alignment: Alignment.topRight,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: InkWell(
                      onTap: () => widget.onClose(_dontShowToday),
                      borderRadius: BorderRadius.circular(22),
                      child: const Center(
                        child: Icon(
                          Icons.close,
                          size: 22,
                          color: AppColors.labelSecondary
                        ),
                      ),
                    ),
                  ),
                ), // Align

                
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 상단 이미지들
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/images/img_TextMerryChristmas.svg',
                            fit: BoxFit.contain,
                          ),

                          const SizedBox(height: 8),

                          Image.asset(
                            'assets/images/img_Christmas.png',
                            fit: BoxFit.contain,
                          ),
                        ],
                      ), // Column

                      const SizedBox(height: 32),

                      // 텍스트
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '특별한 날에도 연습하러 오셨네요!',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySb.copyWith(color:AppColors.labelPrimary)
                          ),
                          SizedBox(height: 2),
                          Text(
                            '오늘도 즐거운 마음으로 시작해볼까요?',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyR.copyWith(color:AppColors.labelPrimary)
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // 확인 버튼 (좋아요!)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(120, 26, 41, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: Color.fromRGBO(179, 69, 82, 1),
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            onPressed: () => widget.onConfirm(_dontShowToday),
                            child: Text(
                              '좋아요!',
                              style: AppTextStyles.bodySb.copyWith(color:AppColors.labelPrimary)
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // "오늘 다시 보지 않기" 체크
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () {
                setState(() {
                  _dontShowToday = !_dontShowToday;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _dontShowToday
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 20,
                      color: _dontShowToday ? Colors.white : Colors.white70,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '오늘 다시 보지 않기',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                    ),
                  ],            
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}