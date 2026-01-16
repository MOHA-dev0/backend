import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ModernLoader extends StatelessWidget {
  final Color? color;
  final double size;

  const ModernLoader({super.key, this.color, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dot(0),
          const SizedBox(width: 4),
          _dot(200),
          const SizedBox(width: 4),
          _dot(400),
        ],
      ),
    );
  }

  Widget _dot(int delay) {
    return Container(
      width: size / 4,
      height: size / 4,
      decoration: BoxDecoration(
        color: color ?? Colors.blue,
        shape: BoxShape.circle,
      ),
    )
    .animate(onPlay: (controller) => controller.repeat(reverse: true))
    .scaleXY(begin: 0.5, end: 1.0, duration: 600.ms, delay: delay.ms, curve: Curves.easeInOut); 
  }
}
