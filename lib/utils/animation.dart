import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WigglingSvgIcon extends StatefulWidget {
  const WigglingSvgIcon({super.key});

  @override
  State<WigglingSvgIcon> createState() => _WigglingSvgIconState();
}

class _WigglingSvgIconState extends State<WigglingSvgIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _animation;
  int _repeatCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = Tween<Offset>(
      begin: const Offset(0.0, -2.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // 애니메이션 상태 리스너 추가
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _repeatCount++;
        if (_repeatCount >= 3) {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              _repeatCount = 0;
              _controller.forward();
            }
          });
        } else {
          _controller.forward();
        }
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(offset: _animation.value, child: child);
      },
      child: SizedBox(
        width: 60,
        child: SvgPicture.asset('assets/images/icon/new_icon.svg'),
      ),
    );
  }
}
