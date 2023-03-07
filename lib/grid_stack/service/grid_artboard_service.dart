import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grid_collage/state_notifier_service.dart';

import '../colors_provider.dart';

final gridArtboardProvider =
    StateNotifierProvider.autoDispose<GridArtboardService, GridArtboardState>(
        (ref) {
  return GridArtboardService();
});

class GridArtboardService extends StateNotifierService<GridArtboardState> {
  GridArtboardService()
      : super(GridArtboardState(
          gridRadius: GridArtboardState.maxGridRaduis / 2,
          dividerThickness: GridArtboardState.maxThicknessWidth / 2,
          adjustMargin: GridArtboardState.maxAdjustMargin / 2,
          borderColor: ColorsProvider.instance.pureColors.first,
        ));

  void updateDividerThickness(double value) {
    state = state.copyWith(dividerThickness: value);
  }

  void updateGridRadius(double value) {
    state = state.copyWith(gridRadius: value);
  }

  void updateShowDivider(bool value) {
    state = state.copyWith(showDivider: value);
  }

  void updateContainerSize(Size size) {
    state = state.copyWith(containerSize: size);
  }

  void updateAdjustMargin(double value) {
    state = state.copyWith(adjustMargin: value);
  }

  void updateBorderWidth(double value) {
    state = state.copyWith(borderWidth: value);
  }

  void updateBorderColor(String value) {
    state = state.copyWith(borderColor: value);
  }
}

@immutable
class GridArtboardState {
  final double dividerThickness;
  final double gridRadius;
  final bool showDivider;
  final Size containerSize;
  final double borderWidth;
  final String borderColor;
  final double adjustMargin;

  const GridArtboardState({
    required this.dividerThickness,
    required this.gridRadius,
    this.showDivider = false,
    this.containerSize = const Size(1242.0, 1242.0),
    this.borderWidth = 0,
    this.borderColor = '',
    this.adjustMargin = 20,
  });

  GridArtboardState copyWith({
    double? dividerThickness,
    double? gridRadius,
    bool? showDivider,
    Size? containerSize,
    double? borderWidth,
    String? borderColor,
    double? adjustMargin,
  }) {
    return GridArtboardState(
      dividerThickness: dividerThickness ?? this.dividerThickness,
      gridRadius: gridRadius ?? this.gridRadius,
      showDivider: showDivider ?? this.showDivider,
      containerSize: containerSize ?? this.containerSize,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
      adjustMargin: adjustMargin ?? this.adjustMargin,
    );
  }

  static double maxGridRaduis = 60.w;
  static double maxThicknessWidth = 96.w;
  static double maxAdjustMargin = 96.w;
  static double defaultDividerWidth = 80.w;
  static double maxBorderWidth = 20.w;
}
