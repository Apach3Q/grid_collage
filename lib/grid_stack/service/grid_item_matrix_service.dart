import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grid_collage/state_notifier_service.dart';

final gridItemMatrixProvider = StateNotifierProvider.family
    .autoDispose<GridItemMatrixService, Matrix4, Key?>((ref, key) {
  return GridItemMatrixService();
});

class GridItemMatrixService extends StateNotifierService<Matrix4> {
  GridItemMatrixService() : super(Matrix4.identity());

  updateMatrix(Matrix4 matrix4) {
    state = matrix4;
  }
}
