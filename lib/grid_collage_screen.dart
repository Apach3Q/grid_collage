import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:grid_collage/actions/grid_collage_action_panel.dart';
import 'package:grid_collage/breath_animator.dart';
import 'package:grid_collage/constant.dart';
import 'package:grid_collage/gradient_view.dart';
import 'package:grid_collage/grid_collage_service.dart';
import 'package:grid_collage/grid_stack/grid_art_board.dart';
import 'package:grid_collage/ripple_button.dart';
import 'dart:ui' as ui;

import 'package:grid_collage/sliding_up_panel.dart';
import 'package:grid_collage/grid_collage_sliding_up_service.dart';

class GridCollageScreen extends StatelessWidget {
  final ZoomDrawerController drawerController;

  const GridCollageScreen({
    super.key,
    required this.drawerController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Constant.gridArtboardBgColor,
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11.w),
                  ),
                  child: FittedBox(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final gridCollageState = ref.watch(gridCollageProvider);
                        final currentGrid = gridCollageState
                            .gridItems[gridCollageState.selectGridIndex];
                        return GridArtBoard(
                          isCaptureWidget: false,
                          gridModel: currentGrid,
                          isThumbnail: false,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: ScreenUtil().statusBarHeight + 20.w,
              left: 20.w,
              width: Constant.actionSizeWidth / 4 * 3,
              height: Constant.actionSizeWidth / 4 * 3,
              child: RippleButton(
                bgColor: Constant.panelBarBgColor,
                borderRadius:
                    BorderRadius.circular(Constant.actionSizeWidth / 4 * 3 / 2),
                height: Constant.actionSizeWidth / 4 * 3,
                onTap: () {
                  final openAction = drawerController.open;
                  if (openAction == null) return;
                  openAction();
                },
                child: GradientView(
                  width: Constant.actionSizeWidth / 4 * 3 / 4 * 3,
                  height: Constant.actionSizeWidth / 4 * 3 / 4 * 3,
                  child: Image.asset(
                    'assets/images/list.png',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class GridCollageMainScreen extends StatelessWidget {
//   final ZoomDrawerController drawerController;

//   const GridCollageMainScreen({
//     super.key,
//     required this.drawerController,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Consumer(
//       builder: (context, ref, child) {
//         final gridCollageSlidingUpState =
//             ref.watch(gridCollageSlidingUpProvider);
//         return SlidingUpPanel(
//           maxHeight: gridCollageSlidingUpState.actionPanelMaxHeight,
//           minHeight: gridCollageSlidingUpState.actionPanelMinHeight,
//           // backdropTapClosesPanel: false,
//           parallaxOffset: .5,
//           controller: gridCollageSlidingUpState.panelController,
//           color: Colors.black,
//           backdropEnabled: true,
//           body: MainScreen(
//             drawerController: drawerController,
//           ),
//           panelBuilder: (scrollController) => Container(
//             child: Column(
//               children: [
//                 SizedBox(
//                   height: 20.w,
//                 ),
//                 ActionPanel(),
//               ],
//             ),
//             // color: Colors.red,
//           ),
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(18.0),
//             topRight: Radius.circular(18.0),
//           ),
//           onPanelSlide: (double pos) {},
//           onPanelClosed: () {
//             final gridCollageSlidingUpSerivce =
//                 ref.read(gridCollageSlidingUpProvider.notifier);
//             gridCollageSlidingUpSerivce.updateGridAction(null);
//           },
//         );
//       },
//     );
//   }
// }

// class MenuScreen extends StatelessWidget {
//   const MenuScreen({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         color: Colors.black, //Color.fromARGB(255, 19, 26, 48),
//         child: Center(
//           child: ListView.builder(
//             itemCount: 2,
//             itemBuilder: (context, index) {
//               if (index == 0) {
//                 return GradientItem(name: 'expand');
//               } else {
//                 return GradientItem(name: 'margin');
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

// class MainScreen extends StatelessWidget {
//   final ZoomDrawerController drawerController;
//   const MainScreen({
//     super.key,
//     required this.drawerController,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ;
//   }
// }

// class GradientItem extends StatelessWidget {
//   final String name;
//   const GradientItem({
//     super.key,
//     required this.name,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         // Navigator.of(context).push(
//         //   MaterialPageRoute<void>(
//         //     builder: (_) => Container(
//         //       color: Colors.yellow,
//         //     ),
//         //   ),
//         // );
//       },
//       child: Container(
//         // color: Colors.red,
//         height: 60,
//         child: Row(
//           children: [
//             SizedBox(width: 20.w),
//             Container(
//               width: 40.w,
//               height: 40.w,
//               // color: Colors.black,
//               child: Center(
//                 child: SizedBox(
//                   width: 40.w,
//                   height: 40.w,
//                   child: ShaderMask(
//                     blendMode: BlendMode.srcIn,
//                     shaderCallback: (Rect bounds) {
//                       return ui.Gradient.linear(
//                         Offset(0, 0),
//                         Offset(40.0, 40.0),
//                         [
//                           Colors.yellow,
//                           Colors.green,
//                           Colors.blue,
//                           Colors.purple,
//                           Colors.pink,
//                         ],
//                         [
//                           0,
//                           0.25,
//                           0.5,
//                           0.75,
//                           1,
//                         ],
//                       );
//                     },
//                     child: Image.asset('assets/images/$name.png'),
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

