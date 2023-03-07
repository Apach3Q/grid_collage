import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:grid_collage/actions/grid_collage_action_panel.dart';
import 'package:grid_collage/constant.dart';
import 'package:grid_collage/grid_collage_screen.dart';
import 'package:grid_collage/grid_collage_sliding_up_service.dart';
import 'package:grid_collage/sliding_up_panel.dart';

class GridCollageMainScreen extends StatelessWidget {
  final ZoomDrawerController drawerController;
  const GridCollageMainScreen({
    super.key,
    required this.drawerController,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final gridCollageSlidingUpState =
            ref.watch(gridCollageSlidingUpProvider);
        return SlidingUpPanel(
          maxHeight: gridCollageSlidingUpState.actionPanelMaxHeight,
          minHeight: gridCollageSlidingUpState.actionPanelMinHeight,
          parallaxOffset: .5,
          controller: gridCollageSlidingUpState.panelController,
          color: Constant.panelBarBgColor,
          backdropEnabled: true,
          backdropOpacity: 0.7,
          isDraggable: false,
          body: GridCollageScreen(
            drawerController: drawerController,
          ),
          panel: _panel(gridCollageSlidingUpState.gridAction),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.w),
            topRight: Radius.circular(20.w),
          ),
          onPanelClosed: () {
            final gridCollageSlidingUpSerivce =
                ref.read(gridCollageSlidingUpProvider.notifier);
            gridCollageSlidingUpSerivce.updateGridAction(
                action: null, manual: false);
          },
        );
      },
    );
  }

  Widget _panel(GridAction? gridAction) {
    List<Widget> columnChildren = [];
    columnChildren.add(SizedBox(height: Constant.actionSpacer));
    columnChildren.add(GridCollageActionPanel());
    return Column(
      children: columnChildren,
    );
  }
}
