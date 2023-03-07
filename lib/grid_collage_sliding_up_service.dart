import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grid_collage/constant.dart';
import 'package:grid_collage/sliding_up_panel.dart';
import 'package:grid_collage/state_notifier_service.dart';

final gridCollageSlidingUpProvider = StateNotifierProvider.autoDispose<
    GridCollageSlidingUpService, GridCollageSlidingUpState>((ref) {
  return GridCollageSlidingUpService(
    read: ref.read,
  );
});

class GridCollageSlidingUpService
    extends StateNotifierService<GridCollageSlidingUpState> {
  final T Function<T>(ProviderListenable<T>) read;

  GridCollageSlidingUpService({
    required this.read,
  }) : super(
          GridCollageSlidingUpState(
            actionPanelMinHeight: ScreenUtil().bottomBarHeight +
                Constant.actionSpacer * 2 +
                Constant.actionSizeWidth,
            actionPanelMaxHeight: ScreenUtil().bottomBarHeight +
                Constant.actionSpacer * 2 +
                Constant.actionSizeWidth +
                100.w,
            panelController: PanelController(),
          ),
        );

  void updateGridAction({
    required GridAction? action,
    required bool manual,
  }) {
    if (action == state.gridAction) {
      state = state.copyWith(gridAction: null);
    } else {
      state = state.copyWith(gridAction: action);
    }
    if (manual) {
      _updatePanelControllerState();
    }
  }

  void _updatePanelControllerState() async {
    final gridAction = state.gridAction;
    if (gridAction == null) {
      if (state.panelController.isPanelOpen) {
        await state.panelController.close();
      }
    } else {
      if (state.panelController.isPanelClosed) {
        await state.panelController.open();
      }
    }
  }
}

@immutable
class GridCollageSlidingUpState {
  final GridAction? gridAction;
  final double actionPanelMinHeight;
  final double actionPanelMaxHeight;
  final PanelController panelController;

  const GridCollageSlidingUpState({
    this.gridAction,
    required this.actionPanelMinHeight,
    required this.actionPanelMaxHeight,
    required this.panelController,
  });

  GridCollageSlidingUpState copyWith({
    required GridAction? gridAction,
    double? actionPanelMinHeight,
    double? actionPanelMaxHeight,
  }) {
    return GridCollageSlidingUpState(
      gridAction: gridAction,
      actionPanelMinHeight: actionPanelMinHeight ?? this.actionPanelMinHeight,
      actionPanelMaxHeight: actionPanelMaxHeight ?? this.actionPanelMaxHeight,
      panelController: panelController,
    );
  }
}
