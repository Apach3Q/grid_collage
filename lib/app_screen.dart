import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:grid_collage/constant.dart';
import 'package:grid_collage/grid_collage_collection_view.dart';
import 'package:grid_collage/grid_collage_main_screen.dart';

class AppScreen extends StatelessWidget {
  final ZoomDrawerController drawerController = ZoomDrawerController();

  AppScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ZoomDrawer(
        menuBackgroundColor: Constant.zoomDrawerBgColor,
        menuScreenOverlayColor: Constant.zoomDrawerBgColor,
        controller: drawerController,
        menuScreen: GridCollageCollectionView(),
        mainScreen: GridCollageMainScreen(
          drawerController: drawerController,
        ),
        borderRadius: 24.0,
        showShadow: false,
        angle: 0.0,
        slideWidth: ScreenUtil().screenWidth * 0.6,
        mainScreenScale: 0.5,
        menuScreenWidth: ScreenUtil().screenWidth * 0.6,
        mainScreenTapClose: true,
      ),
    );
  }
}
