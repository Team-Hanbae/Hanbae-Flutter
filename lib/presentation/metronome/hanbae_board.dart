import 'package:flutter/material.dart';
import 'package:hanbae/model/accent.dart';
import 'package:hanbae/model/jangdan.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import the flutter_bloc package
import 'package:hanbae/bloc/metronome/metronome_bloc.dart';
import 'package:hanbae/theme/colors.dart'; // Import the MetronomeBloc

class HanbaeBoard extends StatelessWidget {
  const HanbaeBoard({super.key, required this.jangdan});
  final Jangdan jangdan;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 372,
      child: Column(
        children: [
          const SizedBox(height: 36.0),
          ...jangdan.accents.asMap().entries.map((rowEntry) {
            final rowIndex = rowEntry.key;
            final row = rowEntry.value;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children:
                      row.asMap().entries.map((colEntry) {
                        final barIndex = colEntry.key;
                        final daebak = colEntry.value;
                        return Expanded(
                          child: BakbarSet(
                            daebak: daebak,
                            rowIndex: rowIndex,
                            barIndex: barIndex,
                          ),
                        );
                      }).toList(),
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 36.0),
        ],
      ),
    );
  }
}

class BakbarSet extends StatelessWidget {
  const BakbarSet({
    super.key,
    required this.daebak,
    required this.rowIndex,
    required this.barIndex,
  });

  final List<Accent> daebak;
  final int rowIndex;
  final int barIndex;

  @override
  Widget build(BuildContext context) {
    final isSobakOn = context.select(
      (MetronomeBloc bloc) => bloc.state.isSobakOn,
    );

    final accentWidgets =
        isSobakOn
            ? daebak
                .asMap()
                .entries
                .map(
                  (entry) => Expanded(
                    child: Bakbar(
                      accent: entry.value,
                      bakNumber: entry.value.name,
                      rowIndex: rowIndex,
                      barIndex: barIndex,
                      accentIndex: entry.key,
                    ),
                  ),
                )
                .toList()
            : [
              Expanded(
                child: Bakbar(
                  accent: daebak.first,
                  bakNumber: daebak.first.name,
                  rowIndex: rowIndex,
                  barIndex: barIndex,
                  accentIndex: 0,
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
              child: Row(children: accentWidgets),
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
    required this.barIndex,
    required this.accentIndex,
  });

  final Accent accent;
  final String bakNumber;
  final int rowIndex;
  final int barIndex;
  final int accentIndex;

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
    return GestureDetector(
      onTap: () {
        context.read<MetronomeBloc>().add(
          ToggleAccent(
            rowIndex: rowIndex,
            barIndex: barIndex,
            accentIndex: accentIndex,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(color: AppColors.frame),
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
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.bakBarActiveTop, AppColors.bakBarActiveBottom],
                    ),
                  ),
                ),
              ),
            ),

            // 상단 숫자
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Text(
                bakNumber,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
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
