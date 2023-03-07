import 'package:flutter/material.dart';

class RippleButton extends StatelessWidget {
  final Function onTap;
  final Widget child;
  final double height;
  final BorderRadius borderRadius;
  final Color bgColor;
  final Color splashColor;

  const RippleButton({
    super.key,
    required this.child,
    required this.onTap,
    this.height = 35,
    this.bgColor = Colors.blue,
    this.splashColor = Colors.white24,
    this.borderRadius = const BorderRadius.all(Radius.circular(0)),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: bgColor,
        ),
        child: InkWell(
          borderRadius: borderRadius,
          splashColor: splashColor,
          child: Container(
            alignment: Alignment.center,
            height: height,
            child: child,
            decoration: BoxDecoration(borderRadius: borderRadius),
          ),
          onTap: () {
            onTap();
          },
        ),
      ),
    );
  }
}
