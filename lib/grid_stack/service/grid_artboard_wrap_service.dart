import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grid_collage/grid_stack/sizes_cache.dart';
import 'package:grid_collage/state_notifier_service.dart';

final gridArtBoardWrapProvider = StateNotifierProvider.family.autoDispose<
    GridArtBoardWrapService,
    GridArtBoardWrapState,
    GridArtBoardWrapServiceParameter>((ref, parameter) {
  return GridArtBoardWrapService();
});

class GridArtBoardWrapService
    extends StateNotifierService<GridArtBoardWrapState> {
  GridArtBoardWrapService() : super(const GridArtBoardWrapState());

  void updateSizes(SizesCache? sizesCache) {
    state = state.copyWith(sizesCache: sizesCache);
  }
}

@immutable
class GridArtBoardWrapState {
  final SizesCache? sizesCache;

  const GridArtBoardWrapState({
    this.sizesCache,
  });

  GridArtBoardWrapState copyWith({
    SizesCache? sizesCache,
  }) {
    return GridArtBoardWrapState(
      sizesCache: sizesCache,
    );
  }
}

class GridArtBoardWrapServiceParameter extends Equatable {
  final String id;
  final bool isThumbnail;
  final bool isCaptureWidget;

  const GridArtBoardWrapServiceParameter({
    required this.id,
    required this.isThumbnail,
    required this.isCaptureWidget,
  });

  @override
  List<Object?> get props => [
        id,
        isThumbnail,
        isCaptureWidget,
      ];
}
