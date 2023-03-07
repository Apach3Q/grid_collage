import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grid_collage/constant.dart';
import 'dart:ui' as ui;

import 'package:grid_collage/grid_collage_sliding_up_service.dart';
import 'package:rotating_icon_button/rotating_icon_button.dart';

class GridCollageActionPanel extends StatelessWidget {
  const GridCollageActionPanel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> rowItems = [];
    for (final action in Constant.gridActions) {
      final spacerWidget = SizedBox(width: Constant.actionSpacer);
      final actionWidget = Container(
        width: Constant.actionSizeWidth,
        height: Constant.actionSizeWidth,
        child: Center(
          child: Consumer(
            builder: (context, ref, child) {
              return RotatingIconButton(
                onTap: () {
                  final slidingUpService =
                      ref.read(gridCollageSlidingUpProvider.notifier);
                  slidingUpService.updateGridAction(
                      action: action, manual: true);
                },
                background: Colors.transparent,
                rotateType: RotateType.quarter,
                shape: ButtonShape.circle,
                child: Container(
                  width: Constant.actionSizeWidth / 4 * 3,
                  height: Constant.actionSizeWidth / 4 * 3,
                  child: GradientActionItem(
                    name: Constant.getActionIcon(action),
                    width: Constant.actionSizeWidth / 4 * 3,
                    height: Constant.actionSizeWidth / 4 * 3,
                    onTap: () {},
                  ),
                ),
              );
            },
          ),
        ),
      );
      rowItems.add(spacerWidget);
      rowItems.add(actionWidget);
    }
    return Row(
      children: rowItems,
    );
  }
}

class GradientActionItem extends StatelessWidget {
  final String name;
  final double width;
  final double height;
  final VoidCallback onTap;

  const GradientActionItem({
    super.key,
    required this.name,
    required this.width,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // onTap: onTap,
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (Rect bounds) {
          return ui.Gradient.linear(
            Offset(0, 0),
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
        child: Image.asset(name),
      ),
    );
  }
}
