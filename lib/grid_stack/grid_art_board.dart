import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'area.dart';
import 'artboard_canvas_service.dart';
import 'grid_art_board_wrap.dart';
import 'matrix_gesture_controller.dart';
import 'model/grid_layout_model.dart';
import 'model/grid_model.dart';
import 'post_frame_mixin.dart';
import 'service/grid_artboard_service.dart';
import 'service/grid_item_matrix_service.dart';
import 'service/grid_item_service.dart';

class GridArtBoard extends StatefulWidget {
  final GridModel gridModel;
  final bool isThumbnail;
  final bool isCaptureWidget;

  const GridArtBoard({
    Key? key,
    required this.gridModel,
    required this.isThumbnail,
    required this.isCaptureWidget,
  }) : super(key: key);

  @override
  State<GridArtBoard> createState() => GridArtBoardState();

  static int getGridCount(GridLayoutModel model, int count) {
    final layout = model.layout;
    if (layout == null) return count + 1;
    int totalCount = 0;
    final children = layout.children;
    for (final child in children) {
      final gridCount = getGridCount(child, 0);
      totalCount += gridCount;
    }
    return totalCount;
  }
}

class GridArtBoardState extends State<GridArtBoard> {
  Map<ValueKey?, Size> gridItemsSizeMap = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final gridArtBoardState = ref.watch(gridArtboardProvider);
        return Container(
          width: gridArtBoardState.containerSize.width,
          height: gridArtBoardState.containerSize.height,
          padding: EdgeInsets.all(
            widget.isThumbnail
                ? GridArtboardState.maxAdjustMargin / 2
                : gridArtBoardState.adjustMargin,
          ),
          child: _gridArtBoard(),
        );
      },
    );
  }

  String _gridId = '';
  late GridSortModel _tempModel;

  Widget _gridArtBoard() {
    if (widget.gridModel.id != _gridId) {
      gridItemsSizeMap = {};
      int gridItemCount = GridArtBoard.getGridCount(widget.gridModel.layout, 0);
      List<GridArtBoardWrapItem> itemList = List<GridArtBoardWrapItem>.generate(
          gridItemCount,
          (int index) => _createItem(
                valueKey:
                    GridArtBoardWrapItem.itemKey(index, widget.isThumbnail),
              ),
          growable: false);
      final gridSortModel = _getGridArtBoard(
        model: widget.gridModel.layout,
        deep: 0,
        itemList: itemList,
      );
      _gridId = widget.gridModel.id;
      _tempModel = gridSortModel;
      return gridSortModel.widget.wrapItem;
    } else {
      return _tempModel.widget.wrapItem;
    }
  }

  GridSortModel _getGridArtBoard({
    required GridLayoutModel model,
    required int deep,
    required List<GridArtBoardWrapItem> itemList,
  }) {
    final layout = model.layout;
    if (layout == null) {
      return GridSortModel(widget: itemList[deep], deep: deep);
    }
    List<GridArea> areas = [];
    List<GridArtBoardWrapItem> gridChildren = [];
    final children = layout.children;
    int newDeep = deep;
    for (final child in children) {
      areas.add(GridArea(weight: child.weight));
      final gridChild = _getGridArtBoard(
        model: child,
        deep: newDeep,
        itemList: itemList,
      );
      newDeep = gridChild.deep;
      newDeep += 1;
      gridChildren.add(gridChild.widget);
    }
    Axis axis;
    if (layout.axis == 'vertical') {
      axis = Axis.vertical;
    } else {
      axis = Axis.horizontal;
    }
    final id = '${widget.gridModel.id}_${deep}_$newDeep';
    Widget artboard = GridArtBoardWrap(
      id: id,
      axis: axis,
      controller: GridArtBoardWrapController(areas: areas),
      antiAliasingWorkaround: false,
      isThumbnail: widget.isThumbnail,
      childSizeUpdate: (ValueKey? valueKey, Size size) {
        gridItemsSizeMap[valueKey] = size;
      },
      children: gridChildren,
      isCaptureWidget: widget.isCaptureWidget,
    );
    return GridSortModel(
      widget: GridArtBoardWrapItem(
        valueKey: const ValueKey(''),
        wrapItem: artboard,
      ),
      deep: newDeep - 1,
    );
  }

  GridArtBoardWrapItem _createItem({
    required ValueKey valueKey,
  }) {
    return GridArtBoardWrapItem(
      valueKey: valueKey,
      wrapItem: Consumer(
        builder: (context, ref, child) {
          final isThumbnail = GridArtBoardWrapItem.isThumbnail(valueKey);
          ValueKey newKey = GridArtBoardWrapItem.wrapItemKey(valueKey);
          final gridItemState = ref.watch(gridItemProvider(newKey));
          final containerSize = gridItemsSizeMap[valueKey];
          return containerSize == null
              ? Container(color: Colors.transparent)
              : Container(
                  child: gridItemState.itemData == null
                      ? Container(color: Colors.transparent)
                      : GridArtBoardItem(
                          itemKey: newKey,
                          containerSize: containerSize,
                          isThumbnail: isThumbnail,
                        ),
                );
        },
      ),
    );
  }
}

class GridArtBoardItem extends ConsumerStatefulWidget {
  final ValueKey? itemKey;
  final Size containerSize;
  final bool isThumbnail;

  const GridArtBoardItem({
    Key? key,
    required this.itemKey,
    required this.containerSize,
    required this.isThumbnail,
  }) : super(key: key);

  @override
  ConsumerState<GridArtBoardItem> createState() => _GridArtBoardItemState();
}

class _GridArtBoardItemState extends ConsumerState<GridArtBoardItem>
    with PostFrameMixin {
  late MatrixGestureController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MatrixGestureController(
      context: context,
      transformRatio: 1,
      shouldRotate: true,
      shouldScale: true,
      shouldTranslate: true,
    );
    if (!widget.isThumbnail) {
      _controller.onMatrixUpdate = (matrix, translationDeltaMatrix,
          scaleDeltaMatrix, rotationDeltaMatrix) {
        final service =
            ref.read(gridItemMatrixProvider(widget.itemKey).notifier);
        service.updateMatrix(matrix);
      };
    }
    postFrame(() {
      if (!widget.isThumbnail) {
        final service =
            ref.read(gridItemMatrixProvider(widget.itemKey).notifier);
        service.updateMatrix(Matrix4.identity());
      }
    });
  }

  Size? itemSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: [
            Consumer(
              builder: (context, ref, child) {
                final gridItemState =
                    ref.watch(gridItemProvider(widget.itemKey));
                final itemData = gridItemState.itemData;
                if (itemData == null) {
                  return Container();
                } else {
                  Size newSize = itemSize ??
                      _getImageSize(widget.containerSize,
                          Size(itemData.width, itemData.height));
                  itemSize = newSize;
                  // final imageSize = _getImageSize(widget.containerSize,
                  //     Size(imageData.width, imageData.height));
                  return Positioned(
                    width: itemSize!.width,
                    height: itemSize!.height,
                    child: Consumer(
                      builder: (context, ref, child) {
                        final state =
                            ref.watch(gridItemMatrixProvider(widget.itemKey));
                        Widget itemWidget = itemData.gridChild;
                        return widget.isThumbnail
                            ? itemWidget
                            : Transform(
                                transform: state,
                                child: itemWidget,
                              );
                      },
                    ),
                  );
                }
              },
            ),
            Consumer(
              builder: (context, ref, child) {
                final gridItemState =
                    ref.watch(gridItemProvider(widget.itemKey));
                final maskWidget = gridItemState.maskWidget;
                return Positioned.fill(
                  child: IgnorePointer(
                    child: widget.isThumbnail ? null : maskWidget,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    final artboardCanvasState = ref.read(artboardCanvasProvider);
    final selectCanvas = artboardCanvasState.selectCanvas;
    if (selectCanvas == null) return;
    if (selectCanvas.kind != ArtboardCanvasKind.grid) return;
    final valueKey = selectCanvas.canvasData as ValueKey;
    if (valueKey != widget.itemKey) return;
    _controller.onScaleStart(details);
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final artboardCanvasState = ref.read(artboardCanvasProvider);
    final selectCanvas = artboardCanvasState.selectCanvas;
    if (selectCanvas == null) return;
    if (selectCanvas.kind != ArtboardCanvasKind.grid) return;
    final valueKey = selectCanvas.canvasData as ValueKey;
    if (valueKey != widget.itemKey) return;
    _controller.onScaleUpdate(details);
  }

  Size _getImageSize(Size containerSize, Size size) {
    double containerWidth = containerSize.width;
    double containerHeight = containerSize.height;
    double containerRatio = containerWidth / containerHeight;
    double width = size.width;
    double height = size.height;
    double ratio = width / height;
    double result = 1;
    if (ratio > containerRatio) {
      result = height / containerHeight;
    } else {
      result = width / containerWidth;
    }
    double imageWidth = width / result;
    double imageHeight = height / result;
    return Size(imageWidth, imageHeight);
  }
}

class GridPlaygroundConfig {
  final double dividerThickness;
  final double radius;
  final double containerWidth;

  GridPlaygroundConfig({
    required this.dividerThickness,
    required this.radius,
    required this.containerWidth,
  });

  GridPlaygroundConfig copyWith({
    double? dividerThickness,
    double? radius,
    double? containerWidth,
  }) =>
      GridPlaygroundConfig(
        dividerThickness: dividerThickness ?? this.dividerThickness,
        radius: radius ?? this.radius,
        containerWidth: containerWidth ?? this.containerWidth,
      );
}

class GridLayout {
  final double weight;
  final GridChildLayout? layout;

  GridLayout({
    required this.weight,
    required this.layout,
  });
}

class GridChildLayout {
  final Axis axis;
  final List<GridLayout> children;

  GridChildLayout({
    required this.axis,
    required this.children,
  });
}

class GridSortModel {
  final GridArtBoardWrapItem widget;
  final int deep;

  GridSortModel({
    required this.widget,
    required this.deep,
  });
}
