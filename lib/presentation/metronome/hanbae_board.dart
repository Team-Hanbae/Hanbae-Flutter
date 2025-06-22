import 'package:flutter/material.dart';
import 'package:hanbae/model/accent.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import the flutter_bloc package
import 'package:hanbae/bloc/metronome/metronome_bloc.dart';
import 'package:hanbae/model/jangdan_type.dart';
import 'package:hanbae/theme/colors.dart'; // Import the MetronomeBloc

class HanbaeBoard extends StatelessWidget {
  const HanbaeBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final jangdan = context.select(
      (MetronomeBloc bloc) => bloc.state.selectedJangdan,
    );

    return Flexible(
      // height: 350,
      child: Column(
        children: [
          SizedBox(
            height:
                (jangdan.jangdanType.sobakSegmentCount != null) ? 16.0 : 28.0,
          ),
          ...jangdan.accents.asMap().entries.map((rowEntry) {
            final rowIndex = rowEntry.key;
            final row = rowEntry.value;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children:
                      row.asMap().entries.map((colEntry) {
                        final daebakIndex = colEntry.key;
                        final daebak = colEntry.value;
                        final bakNumber =
                            jangdan.accents
                                .take(rowIndex)
                                .fold<int>(0, (sum, row) => sum + row.length) +
                            daebakIndex;

                        return Flexible(
                          flex: daebak.length,
                          child: BakbarSet(
                            daebak: daebak,
                            rowIndex: rowIndex,
                            daebakIndex: daebakIndex,
                            bakNumber: bakNumber + 1,
                          ),
                        );
                      }).toList(),
                ),
              ),
            );
          }),
          SizedBox(
            height:
                (jangdan.jangdanType.sobakSegmentCount != null) ? 4.0 : 28.0,
          ),
          if (jangdan.jangdanType.sobakSegmentCount != null) ...[
            SobakSegment(
              sobakSegmentCount: jangdan.jangdanType.sobakSegmentCount!,
              activedSobak: context.select(
                (MetronomeBloc bloc) => bloc.state.currentSobakIndex,
              ),
            ),
            SizedBox(height: 14.0),
          ],
        ],
      ),
    );
  }
}

class SobakSegment extends StatelessWidget {
  final int sobakSegmentCount;
  final int activedSobak;
  const SobakSegment({
    super.key,
    required this.sobakSegmentCount,
    required this.activedSobak,
  });

  @override
  Widget build(BuildContext context) {
    final isSobakOn = context.select(
      (MetronomeBloc bloc) => bloc.state.isSobakOn,
    );
    final isPlaying = context.select(
      (MetronomeBloc bloc) => bloc.state.isPlaying,
    );

    return SizedBox(
      height: 20,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(sobakSegmentCount * 2 - 1, (index) {
                  if (index.isOdd) {
                    return Container(
                      width: 1.0,
                      color:
                          isSobakOn
                              ? AppColors.bakBarBorder
                              : AppColors.bakBarLine,
                    );
                  } else {
                    return Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              isSobakOn
                                  ? isPlaying
                                      ? activedSobak * 2 == index
                                          ? index == 0
                                              ? AppColors.sobakSegmentDaebak
                                              : AppColors.sobakSegmentSobak
                                          : AppColors.frame
                                      : AppColors.frame
                                  : AppColors.frame,
                        ),
                      ),
                    );
                  }
                }),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          isSobakOn
                              ? AppColors.bakBarBorder
                              : AppColors.bakBarLine,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BakbarSet extends StatelessWidget {
  const BakbarSet({
    super.key,
    required this.daebak,
    required this.rowIndex,
    required this.daebakIndex,
    required this.bakNumber,
  });

  final List<Accent> daebak;
  final int rowIndex;
  final int daebakIndex;
  final int bakNumber;

  @override
  Widget build(BuildContext context) {
    final jangdan = context.select(
      (MetronomeBloc bloc) => bloc.state.selectedJangdan,
    );
    final isSobakOn = context.select(
      (MetronomeBloc bloc) => bloc.state.isSobakOn,
    );

    final sobaks =
        isSobakOn && jangdan.jangdanType.sobakSegmentCount == null
            ? daebak
                .asMap()
                .entries
                .map(
                  (entry) => Expanded(
                    child: Bakbar(
                      accent: entry.value,
                      bakNumber: bakNumber,
                      rowIndex: rowIndex,
                      daebakIndex: daebakIndex,
                      sobakIndex: entry.key,
                    ),
                  ),
                )
                .toList()
            : [
              Expanded(
                child: Bakbar(
                  accent: daebak.first,
                  bakNumber: bakNumber,
                  rowIndex: rowIndex,
                  daebakIndex: daebakIndex,
                  sobakIndex: 0,
                ),
              ),
            ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              color: Colors.transparent,
              child: Row(children: sobaks),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.bakBarDivider, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Bakbar extends StatelessWidget {
  const Bakbar({
    super.key,
    required this.accent,
    required this.bakNumber,
    required this.rowIndex,
    required this.daebakIndex,
    required this.sobakIndex,
  });

  final Accent accent;
  final int bakNumber;
  final int rowIndex;
  final int daebakIndex;
  final int sobakIndex;

  double get fillFraction {
    switch (accent) {
      case Accent.none:
        return 0.0;
      case Accent.weak:
        return 1 / 3;
      case Accent.medium:
        return 2 / 3;
      case Accent.strong:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MetronomeBloc>().state;
    final isActive =
        !state.isPlaying ||
        (state.currentRowIndex == rowIndex &&
            state.currentDaebakIndex == daebakIndex &&
            (state.selectedJangdan.jangdanType.sobakSegmentCount != null ||
                (!state.isSobakOn || state.currentSobakIndex == sobakIndex)));
    final isPlaying = context.select(
      (MetronomeBloc bloc) => bloc.state.isPlaying,
    );

    return GestureDetector(
      onTap: () {
        context.read<MetronomeBloc>().add(
          ToggleAccent(
            rowIndex: rowIndex,
            daebakIndex: daebakIndex,
            sobakIndex: sobakIndex,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color:
              !isPlaying
                  ? AppColors.frame
                  : isActive
                  ? Color(0x80FFA91F)
                  : AppColors.frame,
          border: const Border(
            left: BorderSide(color: AppColors.bakBarLine, width: 1),
          ),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter, // 주황 박스를 아래 정렬
          children: [
            CustomPaint(size: Size.infinite, painter: AccentDividerPainter()),

            // 주황 박스
            Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: fillFraction,
                widthFactor: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient:
                        isActive
                            ? const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.bakBarActiveTop,
                                AppColors.bakBarActiveBottom,
                              ],
                            )
                            : null,
                    color: isActive ? null : AppColors.bakBarInactive,
                  ),
                ),
              ),
            ),

            // 상단 숫자
            if (sobakIndex == 0)
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Text(
                  bakNumber.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textDefault,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AccentDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.bakBarDivider
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    const double dashWidth = 2;
    const double dashSpace = 2;
    const double inset = 1.0;

    // 1/3, 2/3 높이에 점선 그리기
    for (var y in [size.height / 3, size.height * 2 / 3]) {
      final adjustedY = y.clamp(inset, size.height - inset);
      double startX = inset;
      while (startX < size.width - inset) {
        canvas.drawLine(
          Offset(startX, adjustedY),
          Offset(startX + dashWidth, adjustedY),
          paint,
        );
        startX += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
