import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grid_collage/state_notifier_service.dart';

final artboardCanvasProvider = StateNotifierProvider.autoDispose<
    ArtboardCanvasService, ArtboardCanvasState>((ref) {
  return ArtboardCanvasService();
});

class ArtboardCanvasService extends StateNotifierService<ArtboardCanvasState> {
  ArtboardCanvasService() : super(const ArtboardCanvasState());

  updateSelectCanvas(SelectArtboardCanvas? canvas) {
    state = state.copyWith(selectCanvas: canvas);
  }
}

@immutable
class ArtboardCanvasState {
  final SelectArtboardCanvas? selectCanvas;

  const ArtboardCanvasState({
    this.selectCanvas,
  });

  ArtboardCanvasState copyWith({
    SelectArtboardCanvas? selectCanvas,
  }) {
    return ArtboardCanvasState(
      selectCanvas: selectCanvas,
    );
  }
}

class SelectArtboardCanvas {
  final ArtboardCanvasKind kind;
  final dynamic canvasData;

  SelectArtboardCanvas({
    required this.kind,
    required this.canvasData,
  });
}

enum ArtboardCanvasKind {
  grid,
  stack,
}
