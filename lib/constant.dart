import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Constant {
  static List<GridAction> gridActions = [
    GridAction.expand,
    GridAction.border,
    GridAction.innerSpacer,
    GridAction.margin,
    GridAction.innerCornerRaidus,
  ];

  static String getActionIcon(GridAction action) {
    switch (action) {
      case GridAction.expand:
        return 'assets/images/expand.png';
      case GridAction.border:
        return 'assets/images/border.png';
      case GridAction.innerSpacer:
        return 'assets/images/inner_spacer.png';
      case GridAction.margin:
        return 'assets/images/margin.png';
      case GridAction.innerCornerRaidus:
        return 'assets/images/inner_corner_raidus.png';
    }
  }

  static int actionCount = gridActions.length;
  static double actionSpacer = 20.w;
  static double actionSizeWidth =
      (ScreenUtil().screenWidth - actionSpacer * 6) / 5;
  static List<Color> gradientColors = [
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.pink,
  ];

  static Color panelBarBgColor = const Color.fromARGB(255, 15, 17, 20);
  static Color zoomDrawerBgColor = const Color.fromARGB(255, 21, 21, 21);
  static Color gridArtboardBgColor = const Color.fromARGB(255, 17, 17, 17);
}

enum GridAction {
  expand,
  border,
  innerSpacer,
  margin,
  innerCornerRaidus,
}

enum GridSizeType {
  oneToOne,
  threeToFour,
  fourToThree,
  nineToSixteen,
  sixteenToNine,
}
