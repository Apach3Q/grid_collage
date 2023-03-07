import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grid_collage/constant.dart';

class GradientBorderView extends StatelessWidget {
  final bool visible;
  final double radius;
  final double margin;
  final Widget child;

  const GradientBorderView({
    super.key,
    required this.visible,
    required this.radius,
    required this.margin,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Visibility(
            visible: visible,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius.w),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: Constant.gradientColors,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: margin.w,
          right: margin.w,
          top: margin.w,
          bottom: margin.w,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular((radius - 2).w),
            ),
          ),
        ),
        Positioned(
          left: margin.w * 2,
          right: margin.w * 2,
          top: margin.w * 2,
          bottom: margin.w * 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular((radius - 4).w),
            child: child,
          ),
        ),
      ],
    );
  }
}
