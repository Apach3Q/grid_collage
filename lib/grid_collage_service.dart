import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grid_collage/grid_provider.dart';
import 'package:grid_collage/grid_stack/model/grid_model.dart';
import 'package:grid_collage/state_notifier_service.dart';

final gridCollageProvider =
    StateNotifierProvider.autoDispose<GridCollageService, GridCollageState>(
        (ref) {
  final grids = GridProvider.instance.grids;
  return GridCollageService(
    read: ref.read,
    gridItems: grids,
  );
});

class GridCollageService extends StateNotifierService<GridCollageState> {
  final T Function<T>(ProviderListenable<T>) read;
  final List<GridModel> gridItems;

  GridCollageService({
    required this.read,
    required this.gridItems,
  }) : super(
          GridCollageState(
            gridItems: gridItems,
          ),
        );

  void updateSelectGrid(int index) {
    state = state.copyWith(selectGridIndex: index);
  }
}

@immutable
class GridCollageState {
  final List<GridModel> gridItems;
  final int selectGridIndex;

  const GridCollageState({
    required this.gridItems,
    this.selectGridIndex = 0,
  });

  GridCollageState copyWith({
    List<GridModel>? gridItems,
    int? selectGridIndex,
  }) {
    return GridCollageState(
      gridItems: gridItems ?? this.gridItems,
      selectGridIndex: selectGridIndex ?? this.selectGridIndex,
    );
  }
}
