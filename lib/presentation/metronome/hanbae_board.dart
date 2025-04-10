import 'package:flutter/material.dart';
import 'package:hanbae/model/accent.dart';
import 'package:hanbae/model/jangdan.dart';

class HanbaeBoard extends StatelessWidget {
  const HanbaeBoard({super.key, required this.jangdan});
  final Jangdan jangdan;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 372,
      child: Column(
        children:
            jangdan.accents.asMap().entries.map((rowEntry) {
              final rowIndex = rowEntry.key;
              final row = rowEntry.value;
              return Expanded(
                child: Row(
                  children: row.asMap().entries.map((colEntry) {
                    final colIndex = colEntry.key;
                    final daebak = colEntry.value;
                    return Expanded(
                      child: BakbarSet(
                        daebak: daebak,
                        rowIndex: rowIndex,
                        colIndexBase: colIndex,
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
      ),
    );
  }
}

class BakbarSet extends StatelessWidget {
  const BakbarSet({
    super.key,
    required this.daebak,
    required this.rowIndex,
    required this.colIndexBase,
  });

  final List<Accent> daebak;
  final int rowIndex;
  final int colIndexBase;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              color: Colors.transparent,
              child: Row(
                children: daebak.asMap().entries
                    .where((entry) => entry.value != Accent.none)
                    .map((entry) => Expanded(
                          child: Bakbar(
                            accent: entry.value,
                            bakNumber: entry.value.name,
                            rowIndex: rowIndex,
                            colIndex: colIndexBase + entry.key,
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
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
    required this.colIndex,
  });

  final Accent accent;
  final String bakNumber;
  final int rowIndex;
  final int colIndex;

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
        debugPrint('Tapped Bakbar at row $rowIndex, col $colIndex');
      },
      child: Container(
        decoration: BoxDecoration(color: Colors.grey),
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
                child: Container(color: Colors.orange),
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
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
          ..color = Colors.black.withAlpha((255 * 0.3).toInt())
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
