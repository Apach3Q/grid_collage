import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grid_collage/state_notifier_service.dart';

final gridItemProvider = StateNotifierProvider.family
    .autoDispose<GridItemService, GridItemState, ValueKey?>((ref, key) {
  return GridItemService();
});

class GridItemService extends StateNotifierService<GridItemState> {
  GridItemService() : super(const GridItemState());

  void updateItem(GridItemData? itemData) {
    state = state.copyWith(
      itemData: itemData,
      maskWidget: state.maskWidget,
    );
  }

  void updateMaskWidget(Widget? maskWidget) {
    state = state.copyWith(
      itemData: state.itemData,
      maskWidget: maskWidget,
    );
  }
}

@immutable
class GridItemState {
  final GridItemData? itemData;
  final Widget? maskWidget;

  const GridItemState({
    this.itemData,
    this.maskWidget,
  });

  GridItemState copyWith({
    GridItemData? itemData,
    Widget? maskWidget,
    TextDirection? textDirection,
  }) {
    return GridItemState(
      itemData: itemData,
      maskWidget: maskWidget,
      // textDirection: textDirection ?? this.textDirection,
    );
  }
}

class GridItemData {
  final Widget gridChild;
  final double width;
  final double height;

  GridItemData({
    required this.gridChild,
    required this.width,
    required this.height,
  });
}
