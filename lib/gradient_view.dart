import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class GradientView extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;

  const GradientView({
    super.key,
    required this.width,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (Rect bounds) {
          return ui.Gradient.linear(
            const Offset(0, 0),
            Offset(width, height),
            [
              Colors.yellow,
              Colors.green,
              Colors.blue,
              Colors.purple,
              Colors.pink,
            ],
            [
              0,
              0.25,
              0.5,
              0.75,
              1,
            ],
          );
        },
        child: child,
      ),
    );
  }
}
