import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grid_collage/app_screen.dart';
import 'package:grid_collage/grid_collage_screen.dart';
import 'package:grid_collage/grid_provider.dart';
import 'package:grid_collage/grid_stack/colors_provider.dart';
import 'dart:ui' as ui;

void main() => runZonedGuarded<Future<void>>(
      () async {
        WidgetsFlutterBinding.ensureInitialized();
        await ColorsProvider.instance.initialized();
        await GridProvider.instance.initialized();
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
            .then(
          (_) async {
            runApp(
              const ProviderScope(
                child: MyApp(),
              ),
            );
          },
        );
      },
      (error, stack) {
        // FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      },
    );

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 667),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Flutter Demo',
          home: AppScreen(),
        );
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 140.w,
          height: 140.w,
          color: Colors.white,
          child: Center(
            child: SizedBox(
              width: 110,
              height: 110,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 10,
                        left: 10,
                        width: 30,
                        bottom: 10,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        width: 30,
                        right: 10,
                        height: 30,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      Positioned(
                        width: 30,
                        right: 10,
                        bottom: 10,
                        height: 30,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // ElevatedButton(
        //   onPressed: () {
        //     Navigator.of(context).push(
        //       MaterialPageRoute<void>(
        //         builder: (_) => GridCollageScreen(),
        //       ),
        //     );
        //   },
        //   child: Text('grid collage'),
        // ),
      ),
    );
  }
}

/**
 * 
 * SizedBox(
              width: 120.w,
              height: 120.w,
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (Rect bounds) {
                  return ui.Gradient.linear(
                    const Offset(0, 0),
                    Offset(120.w, 120.w),
                    [
                      Colors.yellow,
                      Colors.green,
                      Colors.blue,
                      Colors.purple,
                      Colors.pink,
                    ],
                    [
                      0,
                      0.4,
                      0.5,
                      0.6,
                      1,
                    ],
                  );
                },
                child: Image.asset(
                  'assets/images/navi_home.png',
                  // width: 120.w,
                  // height: 120.w,
                ),
              ),
            )
 */

/// 虚线
class DottedLine extends StatelessWidget {
  final double height;
  final Color color;
  final Axis direction;

  const DottedLine({
    this.height = 1,
    this.color = Colors.black,
    this.direction = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = direction == Axis.horizontal
            ? constraints.constrainWidth()
            : constraints.constrainHeight();
        final dashWidth = 10.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor() + 1;
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: direction == Axis.horizontal ? dashWidth : dashHeight,
              height: direction == Axis.horizontal ? dashHeight : dashWidth,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: direction,
        );
      },
    );
  }
}

/**
 * SizedBox(
              width: 110,
              height: 110,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Stack(
                    children: const [
                      Positioned(
                        top: 10,
                        left: 0,
                        right: 0,
                        height: 10,
                        child: DottedLine(
                          height: 10,
                          color: Colors.black,
                          direction: Axis.horizontal,
                        ),
                      ),
                      Positioned(
                        top: 70,
                        left: 0,
                        right: 0,
                        height: 10,
                        child: DottedLine(
                          height: 10,
                          color: Colors.black,
                          direction: Axis.horizontal,
                        ),
                      ),
                      Positioned(
                        left: 10,
                        top: 0,
                        bottom: 0,
                        width: 10,
                        child: DottedLine(
                          height: 10,
                          color: Colors.black,
                          direction: Axis.vertical,
                        ),
                      ),
                      Positioned(
                        left: 70,
                        top: 0,
                        bottom: 0,
                        width: 10,
                        child: DottedLine(
                          height: 10,
                          color: Colors.black,
                          direction: Axis.vertical,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
 */