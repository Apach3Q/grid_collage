import 'package:flutter/material.dart';

class BreathAnimator extends StatefulWidget {
  final Widget breathChild;

  const BreathAnimator({
    Key? key,
    required this.breathChild,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BreathAnimatorState();
}

class _BreathAnimatorState extends State<BreathAnimator>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;
  AnimationStatus status = AnimationStatus.forward;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    animation = Tween(begin: 0.9, end: 1.1).animate(animationController)
      ..addListener(() {
        if (animationController.status != AnimationStatus.dismissed &&
            animationController.status != AnimationStatus.completed) {
          status = animationController.status;
        }
        if (animationController.status == AnimationStatus.completed ||
            animationController.status == AnimationStatus.dismissed) {
          status == AnimationStatus.forward
              ? animationController.reverse()
              : animationController.forward();
        }
      });
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Transform.scale(
        scale: animation.value,
        child: widget.breathChild,
      ),
    );
  }
}
