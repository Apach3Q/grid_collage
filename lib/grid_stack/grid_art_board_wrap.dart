import 'dart:collection';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'area.dart';
import 'artboard_canvas_service.dart';
import 'service/grid_artboard_service.dart';
import 'service/grid_artboard_wrap_service.dart';
import 'sizes_cache.dart';

double minGridItemWidth = 50.0;

/// Controller for [GridArtBoardWrap].
///
/// It is not allowed to share this controller between [GridArtBoardWrap]
/// instances.
class GridArtBoardWrapController extends ChangeNotifier {
  static const double _higherPrecision = 1.0000000000001;

  /// Creates an [GridArtBoardWrapController].
  ///
  /// The sum of the [weights] cannot exceed 1.
  factory GridArtBoardWrapController({
    List<GridArea>? areas,
  }) {
    return GridArtBoardWrapController._(areas != null ? List.from(areas) : []);
  }

  GridArtBoardWrapController._(this._areas);

  List<GridArea> _areas;

  UnmodifiableListView<GridArea> get areas => UnmodifiableListView(_areas);

  set areas(List<GridArea> areas) {
    _areas = List.from(areas);
    notifyListeners();
  }

  /// Gets the area of a given widget index.
  GridArea getArea(int index) {
    return _areas[index];
  }

  /// Sum of all weights.
  double _weightSum() {
    double sum = 0;
    _areas.forEach((area) {
      sum += area.weight ?? 0;
    });
    return sum;
  }

  /// Adjusts the weights according to the number of children.
  /// New children will receive a percentage of current children.
  /// Excluded children will distribute their weights to the existing ones.
  @visibleForTesting
  void fixWeights(
      {required int childrenCount,
      required double fullSize,
      required double dividerThickness}) {
    childrenCount = math.max(childrenCount, 0);

    final double totalDividerSize = (childrenCount - 1) * dividerThickness;
    final double availableSize = fullSize - totalDividerSize;

    int nullWeightCount = 0;
    for (int i = 0; i < _areas.length; i++) {
      GridArea area = _areas[i];
      if (area.size != null) {
        _areas[i] = area.copyWithNewWeight(weight: area.size! / availableSize);
      }
      if (area.weight == null) {
        nullWeightCount++;
      }
    }

    double weightSum = _weightSum();

    // fill null weights
    if (nullWeightCount > 0) {
      double r = 0;
      if (weightSum < GridArtBoardWrapController._higherPrecision) {
        r = (1 - weightSum) / nullWeightCount;
      }
      for (int i = 0; i < _areas.length; i++) {
        GridArea area = _areas[i];
        if (area.weight == null) {
          _areas[i] = area.copyWithNewWeight(weight: r);
        }
      }
      weightSum = _weightSum();
    }

    // removing over weight...
    if (weightSum > GridArtBoardWrapController._higherPrecision) {
      final over = weightSum - 1;
      double r = over / weightSum;
      for (int i = 0; i < _areas.length; i++) {
        GridArea area = _areas[i];
        _areas[i] =
            area.copyWithNewWeight(weight: area.weight! - (area.weight! * r));
      }
    }

    if (_areas.length == childrenCount) {
      _fillWeightsEqually(childrenCount, weightSum);
      _applyMinimal(availableSize: availableSize);
      return;
    } else if (_areas.length < childrenCount) {
      // children has been added.
      int addedChildrenCount = childrenCount - _areas.length;
      double newWeight = 0;
      if (weightSum < 1) {
        newWeight = (1 - weightSum) / addedChildrenCount;
      } else {
        for (int i = 0; i < _areas.length; i++) {
          GridArea area = _areas[i];
          double r = area.weight! / childrenCount;
          _areas[i] = area.copyWithNewWeight(weight: area.weight! - r);
          newWeight += r / addedChildrenCount;
        }
      }
      for (int i = 0; i < addedChildrenCount; i++) {
        _areas.add(GridArea(weight: newWeight));
      }
    } else {
      // children has been removed.
      double removedWeight = 0;
      while (_areas.length > childrenCount) {
        removedWeight += _areas.removeLast().weight!;
      }
      if (_areas.isNotEmpty) {
        double w = removedWeight / _areas.length;
        for (int i = 0; i < _areas.length; i++) {
          GridArea area = _areas[i];
          _areas[i] = area.copyWithNewWeight(weight: area.weight! + w);
        }
      }
    }
    _fillWeightsEqually(childrenCount, _weightSum());
    _applyMinimal(availableSize: availableSize);
  }

  /// Fills equally the missing weights
  void _fillWeightsEqually(int childrenCount, double weightSum) {
    if (weightSum < 1) {
      double availableWeight = 1 - weightSum;
      if (availableWeight > 0) {
        double w = availableWeight / childrenCount;
        for (int i = 0; i < _areas.length; i++) {
          GridArea area = _areas[i];
          _areas[i] = area.copyWithNewWeight(weight: area.weight! + w);
        }
      }
    }
  }

  /// Fix the weights to the minimal size/weight.
  void _applyMinimal({required double availableSize}) {
    double totalNonMinimalWeight = 0;
    double totalMinimalWeight = 0;
    int minimalCount = 0;
    for (int i = 0; i < _areas.length; i++) {
      GridArea area = _areas[i];
      if (area.minimalSize != null) {
        double minimalWeight = area.minimalSize! / availableSize;
        totalMinimalWeight += minimalWeight;
        minimalCount++;
      } else if (area.minimalWeight != null) {
        totalMinimalWeight += area.minimalWeight!;
        minimalCount++;
      } else {
        totalNonMinimalWeight += area.weight!;
      }
    }
    if (totalMinimalWeight > 0) {
      double reducerMinimalWeight = 0;
      if (totalMinimalWeight > 1) {
        reducerMinimalWeight = ((totalMinimalWeight - 1) / minimalCount);
        totalMinimalWeight = 1;
      }
      double totalReducerNonMinimalWeight = 0;
      if (totalMinimalWeight + totalNonMinimalWeight > 1) {
        totalReducerNonMinimalWeight =
            (totalMinimalWeight + totalNonMinimalWeight - 1);
      }
      for (int i = 0; i < _areas.length; i++) {
        GridArea area = _areas[i];
        if (area.minimalSize != null) {
          double minimalWeight = math.max(
              0, (area.minimalSize! / availableSize) - reducerMinimalWeight);
          if (area.weight! < minimalWeight) {
            _areas[i] = area.copyWithNewWeight(weight: minimalWeight);
          }
        } else if (area.minimalWeight != null) {
          double minimalWeight =
              math.max(0, area.minimalWeight! - reducerMinimalWeight);
          if (area.weight! < minimalWeight) {
            _areas[i] = area.copyWithNewWeight(weight: minimalWeight);
          }
        } else if (totalReducerNonMinimalWeight > 0) {
          double reducer = totalReducerNonMinimalWeight *
              area.weight! /
              totalNonMinimalWeight;
          double newWeight = math.max(0, area.weight! - reducer);
          _areas[i] = area.copyWithNewWeight(weight: newWeight);
        }
      }
    }
  }

  /// Stores the hashCode of the state to identify if a controller instance
  /// is being shared by multiple [GridArtBoardWrap]. The application must not
  /// manipulate this attribute, it is for the internal use of the package.
  int? _stateHashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridArtBoardWrapController &&
          runtimeType == other.runtimeType &&
          _areas == other._areas;

  @override
  int get hashCode => _areas.hashCode;

  int get weightsHashCode => Object.hashAll(_WeightIterable(areas));
}

class _WeightIterable extends Iterable<double?> {
  _WeightIterable(this.areas);

  final List<GridArea> areas;

  @override
  Iterator<double?> get iterator => _WeightIterator(areas);
}

class _WeightIterator extends Iterator<double?> {
  _WeightIterator(this.areas);

  final List<GridArea> areas;
  int _index = -1;

  @override
  double? get current => areas[_index].weight;

  @override
  bool moveNext() {
    _index++;
    return _index > -1 && _index < areas.length;
  }
}

class GridArtBoardWrap extends ConsumerStatefulWidget {
  static const Axis defaultAxis = Axis.horizontal;

  GridArtBoardWrap({
    Key? key,
    this.axis = GridArtBoardWrap.defaultAxis,
    required this.children,
    required this.childSizeUpdate,
    required this.controller,
    required this.isThumbnail,
    required this.id,
    this.onWeightChange,
    this.antiAliasingWorkaround = true,
    required this.isCaptureWidget,
  }) : super(key: key);

  final Axis axis;
  final List<GridArtBoardWrapItem> children;
  final GridArtBoardWrapController controller;
  final bool isThumbnail;
  final void Function(ValueKey?, Size) childSizeUpdate;
  final String id;
  final bool isCaptureWidget;

  /// Function to listen children weight change.
  /// The listener will run on the parent's resize or
  /// on the dragging end of the divisor.
  final OnWeightChange? onWeightChange;

  /// Enables a workaround for https://github.com/flutter/flutter/issues/14288
  final bool antiAliasingWorkaround;

  @override
  ConsumerState createState() => _GridArtBoardWrapState();
}

/// State for [GridArtBoardWrap]
class _GridArtBoardWrapState extends ConsumerState<GridArtBoardWrap> {
  late GridArtBoardWrapController _controller;
  _InitialDrag? _initialDrag;
  // SizesCache? _sizesCache;
  int? _weightsHashCode;

  GridArtBoardWrapServiceParameter get parameter =>
      GridArtBoardWrapServiceParameter(
        id: widget.id,
        isThumbnail: widget.isThumbnail,
        isCaptureWidget: false,
      );

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _stateHashCodeValidation();
    _controller._stateHashCode = hashCode;
    _controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    final gridArtboardWrapService =
        ref.read(gridArtBoardWrapProvider(parameter).notifier);
    gridArtboardWrapService.updateSizes(null);
    // setState(() {
    //   _sizesCache = null;
    // });
  }

  @override
  void deactivate() {
    _controller._stateHashCode = null;
    super.deactivate();
  }

  @override
  void didUpdateWidget(GridArtBoardWrap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.id != widget.id) {
      final gridArtboardWrapService =
          ref.read(gridArtBoardWrapProvider(parameter).notifier);
      // gridArtboardWrapService.updateSizes(null);
      // _sizesCache = null;
      _controller._stateHashCode = null;
      _controller.removeListener(_rebuild);

      _controller = widget.controller;
      _stateHashCodeValidation();
      _controller._stateHashCode = hashCode;
      _controller.addListener(_rebuild);
    }
  }

  /// Checks a controller's [_stateHashCode] to identify if it is
  /// not being shared by another instance of [GridArtBoardWrap].
  void _stateHashCodeValidation() {
    if (_controller._stateHashCode != null &&
        _controller._stateHashCode != hashCode) {
      throw StateError(
          'It is not allowed to share GridArtBoardWrapController between GridArtBoardWrap instances.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final artboardState = ref.watch(gridArtboardProvider);
    final gridArtboardWrapState =
        ref.watch(gridArtBoardWrapProvider(parameter));
    double dividerThickness = widget.isThumbnail
        ? GridArtboardState.maxThicknessWidth / 2
        : artboardState.dividerThickness;
    if (widget.children.isNotEmpty) {
      double totalDividerSize = (widget.children.length - 1) * dividerThickness;
      return LayoutBuilder(builder: (context, constraints) {
        List<Widget> children = [];
        if (widget.axis == Axis.horizontal) {
          _controller.fixWeights(
              childrenCount: widget.children.length,
              fullSize: constraints.maxWidth,
              dividerThickness: dividerThickness);
          SizesCache? sizesCache;
          if (gridArtboardWrapState.sizesCache == null ||
              gridArtboardWrapState.sizesCache!.childrenCount !=
                  widget.children.length ||
              gridArtboardWrapState.sizesCache!.fullSize !=
                  constraints.maxWidth ||
              dividerThickness !=
                  gridArtboardWrapState.sizesCache!.dividerThickness) {
            sizesCache = SizesCache(
              areas: _controller._areas,
              fullSize: constraints.maxWidth,
              dividerThickness: dividerThickness,
            );
          } else {
            sizesCache = gridArtboardWrapState.sizesCache;
          }
          // if (_sizesCache == null ||
          //     _sizesCache!.childrenCount != widget.children.length ||
          //     _sizesCache!.fullSize != constraints.maxWidth ||
          //     dividerThickness != _sizesCache!.dividerThickness) {
          //   _sizesCache = SizesCache(
          //       areas: _controller._areas,
          //       fullSize: constraints.maxWidth,
          //       dividerThickness: dividerThickness);
          // }
          _populateHorizontalChildren(
            context: context,
            constraints: constraints,
            totalDividerSize: totalDividerSize,
            children: children,
            fullSize: constraints.maxWidth,
            sizesCache: sizesCache,
          );
        } else {
          _controller.fixWeights(
              childrenCount: widget.children.length,
              fullSize: constraints.maxHeight,
              dividerThickness: dividerThickness);
          SizesCache? sizesCache;
          if (gridArtboardWrapState.sizesCache == null ||
              gridArtboardWrapState.sizesCache!.childrenCount !=
                  widget.children.length ||
              gridArtboardWrapState.sizesCache!.fullSize !=
                  constraints.maxHeight ||
              dividerThickness !=
                  gridArtboardWrapState.sizesCache!.dividerThickness) {
            // final gridArtboardWrapService =
            // ref.read(gridArtBoardWrapProvider(parameter).notifier);
            sizesCache = SizesCache(
                areas: _controller._areas,
                fullSize: constraints.maxHeight,
                dividerThickness: dividerThickness);
          } else {
            sizesCache = gridArtboardWrapState.sizesCache;
          }
          // if (_sizesCache == null ||
          //     _sizesCache!.childrenCount != widget.children.length ||
          //     _sizesCache!.fullSize != constraints.maxHeight ||
          //     dividerThickness != _sizesCache!.dividerThickness) {
          //   _sizesCache = SizesCache(
          //       areas: _controller._areas,
          //       fullSize: constraints.maxHeight,
          //       dividerThickness: dividerThickness);
          // }
          _populateVerticalChildren(
            context: context,
            constraints: constraints,
            totalDividerSize: totalDividerSize,
            children: children,
            fullSize: constraints.maxHeight,
            sizesCache: sizesCache,
          );
        }

        if (widget.onWeightChange != null) {
          int newWeightsHashCode = _controller.weightsHashCode;
          if (_weightsHashCode != null &&
              _weightsHashCode != newWeightsHashCode) {
            Future.microtask(widget.onWeightChange!);
          }
          _weightsHashCode = newWeightsHashCode;
        }

        return Stack(children: children);
      });
    }
    return Container();
  }

  /// Applies the horizontal layout
  void _populateHorizontalChildren({
    required BuildContext context,
    required BoxConstraints constraints,
    required double totalDividerSize,
    required List<Widget> children,
    required double fullSize,
    required SizesCache? sizesCache,
  }) {
    final artboardState = ref.watch(gridArtboardProvider);
    double dividerThickness = widget.isThumbnail
        ? GridArtboardState.maxThicknessWidth / 2
        : artboardState.dividerThickness;
    _DistanceFrom childDistance = _DistanceFrom();
    for (int childIndex = 0;
        childIndex < widget.children.length;
        childIndex++) {
      final double childSize = sizesCache!.sizes[childIndex];
      childDistance.right = fullSize - childSize - childDistance.left;
      final size = Size(fullSize - childDistance.left - childDistance.right,
          constraints.maxHeight);
      final gridChild = widget.children[childIndex];
      bool isGridItem = gridChild.wrapItem is! GridArtBoardWrap;
      final gridChildKey = gridChild.valueKey;
      if (isGridItem) {
        widget.childSizeUpdate(gridChildKey, size);
      }
      children.add(_buildChildPositioned(
        distance: childDistance,
        gridChild: gridChild,
      ));
      childDistance.left = childDistance.left + childSize + dividerThickness;
    }
    childDistance.left = 0;
    for (int i = 0; i < widget.children.length; i++) {
      final double childSize = sizesCache!.sizes[i];
      if (i < widget.children.length - 1) {
        _DistanceFrom dividerDistance = _DistanceFrom();
        dividerDistance.left = childDistance.left +
            childSize +
            dividerThickness / 2 -
            GridArtboardState.defaultDividerWidth / 2;
        dividerDistance.right = fullSize -
            childSize -
            childDistance.left -
            dividerThickness / 2 -
            GridArtboardState.defaultDividerWidth / 2;
        dividerDistance.top = constraints.maxHeight / 2 -
            GridArtboardState.defaultDividerWidth / 2;
        dividerDistance.bottom = constraints.maxHeight / 2 -
            GridArtboardState.defaultDividerWidth / 2;

        if (artboardState.showDivider) {
          Widget dividerWidget = SizedBox(
            width: GridArtboardState.defaultDividerWidth,
            height: GridArtboardState.defaultDividerWidth,
            child: widget.isCaptureWidget ? null : _divider(),
          );
          dividerWidget = GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragStart: (detail) {
                final pos = _position(context, detail.globalPosition);
                _updateInitialDrag(i, pos.dx, sizesCache);
              },
              onHorizontalDragEnd: (detail) => _onDragEnd(sizesCache),
              onHorizontalDragUpdate: (detail) {
                final pos = _position(context, detail.globalPosition);
                double diffX = pos.dx - _initialDrag!.initialDragPos;

                _updateDifferentWeights(
                  childIndex: i,
                  diffPos: diffX,
                  fullSize: fullSize,
                  pos: pos.dx,
                  sizesCache: sizesCache,
                );
              },
              child: dividerWidget);
          children.add(
            _buildDividerPositioned(
              distance: dividerDistance,
              child: dividerWidget,
            ),
          );
        }
        childDistance.left = childDistance.left + childSize + dividerThickness;
      }
    }
  }

  /// Applies the vertical layout
  void _populateVerticalChildren({
    required BuildContext context,
    required BoxConstraints constraints,
    required double totalDividerSize,
    required List<Widget> children,
    required double fullSize,
    required SizesCache? sizesCache,
  }) {
    final artboardState = ref.watch(gridArtboardProvider);
    double dividerThickness = widget.isThumbnail
        ? GridArtboardState.maxThicknessWidth / 2
        : artboardState.dividerThickness;
    _DistanceFrom childDistance = _DistanceFrom();
    for (int i = 0; i < widget.children.length; i++) {
      final double childSize = sizesCache!.sizes[i];
      childDistance.bottom = fullSize - childSize - childDistance.top;
      final size = Size(constraints.maxWidth,
          fullSize - childDistance.top - childDistance.bottom);
      final gridChild = widget.children[i];
      bool isGridItem = gridChild.wrapItem is! GridArtBoardWrap;
      final gridChildKey = gridChild.valueKey;
      if (isGridItem) {
        widget.childSizeUpdate(gridChildKey, size);
      }
      children.add(_buildChildPositioned(
        distance: childDistance,
        gridChild: gridChild,
        last: i == widget.children.length - 1,
      ));
      childDistance.top = childDistance.top + childSize + dividerThickness;
    }
    childDistance.top = 0;
    for (int i = 0; i < widget.children.length; i++) {
      final double childSize = sizesCache!.sizes[i];
      if (i < widget.children.length - 1) {
        _DistanceFrom dividerDistance = _DistanceFrom();
        dividerDistance.top = childDistance.top +
            childSize +
            dividerThickness / 2 -
            GridArtboardState.defaultDividerWidth / 2;
        dividerDistance.bottom = fullSize -
            childSize -
            childDistance.top -
            dividerThickness / 2 -
            GridArtboardState.defaultDividerWidth / 2;
        dividerDistance.left = constraints.maxWidth / 2 -
            GridArtboardState.defaultDividerWidth / 2;
        dividerDistance.right = constraints.maxWidth / 2 -
            GridArtboardState.defaultDividerWidth / 2;

        if (artboardState.showDivider) {
          Widget dividerWidget = SizedBox(
            width: GridArtboardState.defaultDividerWidth,
            height: GridArtboardState.defaultDividerWidth,
            child: RotatedBox(
              quarterTurns: 1,
              child: widget.isCaptureWidget ? null : _divider(),
            ),
          );
          dividerWidget = GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragStart: (detail) {
                final pos = _position(context, detail.globalPosition);
                _updateInitialDrag(i, pos.dy, sizesCache);
              },
              onVerticalDragEnd: (detail) => _onDragEnd(sizesCache),
              onVerticalDragUpdate: (detail) {
                final pos = _position(context, detail.globalPosition);
                double diffY = pos.dy - _initialDrag!.initialDragPos;
                _updateDifferentWeights(
                  childIndex: i,
                  diffPos: diffY,
                  fullSize: fullSize,
                  pos: pos.dy,
                  sizesCache: sizesCache,
                );
              },
              child: dividerWidget);
          children.add(_buildDividerPositioned(
            distance: dividerDistance,
            child: dividerWidget,
          ));
        }

        childDistance.top = childDistance.top + childSize + dividerThickness;
      }
    }
  }

  Widget _divider() {
    return Container(
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(GridArtboardState.defaultDividerWidth / 2),
        color: Colors.white,
      ),
      child: Image.asset(
        'assets/images/tabbar_scene/home_tab/grid_collage/adjust_expand_icon.png',
        width: GridArtboardState.defaultDividerWidth,
        height: GridArtboardState.defaultDividerWidth,
      ),
    );
  }

  void _onDragEnd(
    SizesCache? sizesCache,
  ) {
    if (sizesCache == null) return;
    for (int i = 0; i < _controller._areas.length; i++) {
      GridArea area = _controller._areas[i];
      double size = sizesCache.sizes[i];
      _controller._areas[i] =
          area.copyWithNewWeight(weight: size / sizesCache.childrenSize);
    }
  }

  void _updateInitialDrag(
    int childIndex,
    double initialDragPos,
    SizesCache? sizesCache,
  ) {
    if (sizesCache == null) return;
    final double initialChild1Size = sizesCache.sizes[childIndex];
    final double initialChild2Size = sizesCache.sizes[childIndex + 1];
    final double minimalChild1Size = sizesCache.minimalSizes[childIndex];
    final double minimalChild2Size = sizesCache.minimalSizes[childIndex + 1];
    final double sumMinimals = minimalChild1Size + minimalChild2Size;
    final double sumSizes = initialChild1Size + initialChild2Size;

    double posLimitStart = 0;
    double posLimitEnd = 0;
    double child1Start = 0;
    double child2End = 0;
    for (int i = 0; i <= childIndex; i++) {
      if (i < childIndex) {
        child1Start += sizesCache.sizes[i];
        child1Start += sizesCache.dividerThickness;
        child2End += sizesCache.sizes[i];
        child2End += sizesCache.dividerThickness;
        posLimitStart += sizesCache.sizes[i];
        posLimitStart += sizesCache.dividerThickness;
        posLimitEnd += sizesCache.sizes[i];
        posLimitEnd += sizesCache.dividerThickness;
      } else if (i == childIndex) {
        posLimitStart += sizesCache.minimalSizes[i];
        posLimitEnd += sizesCache.sizes[i];
        posLimitEnd += sizesCache.dividerThickness;
        posLimitEnd += sizesCache.sizes[i + 1];
        child2End += sizesCache.sizes[i];
        child2End += sizesCache.dividerThickness;
        child2End += sizesCache.sizes[i + 1];
        posLimitEnd = math.max(
            posLimitStart, posLimitEnd - sizesCache.minimalSizes[i + 1]);
      }
    }

    _initialDrag = _InitialDrag(
        initialDragPos: initialDragPos,
        initialChild1Size: initialChild1Size,
        initialChild2Size: initialChild2Size,
        minimalChild1Size: minimalChild1Size,
        minimalChild2Size: minimalChild2Size,
        sumMinimals: sumMinimals,
        sumSizes: sumSizes,
        child1Start: child1Start,
        child2End: child2End,
        posLimitStart: posLimitStart,
        posLimitEnd: posLimitEnd);
    _initialDrag!.posBeforeMinimalChild1 = initialDragPos < posLimitStart;
    _initialDrag!.posAfterMinimalChild2 = initialDragPos > posLimitEnd;
  }

  /// Calculates the new weights and sets if they are different from the current one.
  void _updateDifferentWeights({
    required int childIndex,
    required double diffPos,
    required double pos,
    required double fullSize,
    required SizesCache? sizesCache,
  }) {
    if (diffPos == 0) {
      return;
    }

    if (_initialDrag!.sumMinimals >= _initialDrag!.sumSizes) {
      // minimals already smaller than available space. Ignoring...
      return;
    }

    double newChild1Size;
    double newChild2Size;

    if (diffPos.isNegative) {
      // divider moving on left/top from initial mouse position
      if (_initialDrag!.posBeforeMinimalChild1) {
        // can't shrink, already smaller than minimal
        return;
      }
      newChild1Size = math.max(_initialDrag!.minimalChild1Size,
          _initialDrag!.initialChild1Size + diffPos);
      newChild2Size = _initialDrag!.sumSizes - newChild1Size;

      if (_initialDrag!.posAfterMinimalChild2) {
        if (newChild2Size > _initialDrag!.minimalChild2Size) {
          _initialDrag!.posAfterMinimalChild2 = false;
        }
      } else if (newChild2Size < _initialDrag!.minimalChild2Size) {
        double diff = _initialDrag!.minimalChild2Size - newChild2Size;
        newChild2Size += diff;
        newChild1Size -= diff;
      }
    } else {
      // divider moving on right/bottom from initial mouse position
      if (_initialDrag!.posAfterMinimalChild2) {
        // can't shrink, already smaller than minimal
        return;
      }
      newChild2Size = math.max(_initialDrag!.minimalChild2Size,
          _initialDrag!.initialChild2Size - diffPos);
      newChild1Size = _initialDrag!.sumSizes - newChild2Size;

      if (_initialDrag!.posBeforeMinimalChild1) {
        if (newChild1Size > _initialDrag!.minimalChild1Size) {
          _initialDrag!.posBeforeMinimalChild1 = false;
        }
      } else if (newChild1Size < _initialDrag!.minimalChild1Size) {
        double diff = _initialDrag!.minimalChild1Size - newChild1Size;
        newChild1Size += diff;
        newChild2Size -= diff;
      }
    }
    if (newChild1Size >= minGridItemWidth &&
        newChild2Size >= minGridItemWidth) {
      final gridArtboardWrapService =
          ref.read(gridArtBoardWrapProvider(parameter).notifier);
      if (sizesCache == null) return;
      SizesCache? _sizesCache = sizesCache;
      _sizesCache.sizes[childIndex] = newChild1Size;
      _sizesCache.sizes[childIndex + 1] = newChild2Size;
      gridArtboardWrapService.updateSizes(_sizesCache);

      // setState(() {
      //   _sizesCache!.sizes[childIndex] = newChild1Size;
      //   _sizesCache!.sizes[childIndex + 1] = newChild2Size;
      // });
    }
  }

  /// Builds an [Offset] for cursor position.
  Offset _position(BuildContext context, Offset globalPosition) {
    final RenderBox container = context.findRenderObject() as RenderBox;
    return container.globalToLocal(globalPosition);
  }

  Positioned _buildChildPositioned({
    required _DistanceFrom distance,
    required GridArtBoardWrapItem gridChild,
    bool last = false,
  }) {
    bool isGridItem = gridChild.wrapItem is! GridArtBoardWrap;
    Positioned positioned = Positioned(
      top: _convert(distance.top, last),
      left: _convert(distance.left, last),
      right: _convert(distance.right, last),
      bottom: _convert(distance.bottom, last),
      child: Consumer(
        builder: (context, ref, child) {
          final gridArtboardState = ref.watch(gridArtboardProvider);
          final artboardState = ref.watch(gridArtboardProvider);
          final artboardCanvasState = ref.watch(artboardCanvasProvider);
          final selectCanvas = artboardCanvasState.selectCanvas;
          String selectedGridKey;
          if (selectCanvas == null) {
            selectedGridKey = '';
          } else {
            if (selectCanvas.kind == ArtboardCanvasKind.grid) {
              final valueKey = selectCanvas.canvasData as ValueKey;
              selectedGridKey = GridArtBoardWrapItem.prefix(valueKey);
            } else {
              selectedGridKey = '';
            }
          }
          final gridChildKey = GridArtBoardWrapItem.prefix(gridChild.valueKey);
          Container(
            decoration: BoxDecoration(),
          );
          return Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.isThumbnail
                        ? GridArtboardState.maxGridRaduis / 2
                        : gridArtboardState.gridRadius),
                    color: widget.isCaptureWidget
                        ? null
                        : (isGridItem
                            ? const Color.fromARGB(255, 181, 181, 181)
                            : null),
                  ),
                ),
              ),
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    final artboardCanvasState =
                        ref.read(artboardCanvasProvider);
                    final artboardCanvasService =
                        ref.read(artboardCanvasProvider.notifier);
                    final gridChildKey =
                        GridArtBoardWrapItem.wrapItemKey(gridChild.valueKey);
                    final selectCanvas = artboardCanvasState.selectCanvas;
                    if (selectCanvas != null &&
                        selectCanvas.kind == ArtboardCanvasKind.grid) {
                      final valueKey = selectCanvas.canvasData as ValueKey;
                      if (gridChildKey == valueKey) {
                        String valueKeyValue = gridChild.valueKey.value;
                        if (!valueKeyValue
                            .contains('${GridArtBoardWrapItem._midFix}true')) {
                          artboardCanvasService.updateSelectCanvas(null);
                        }
                      } else {
                        artboardCanvasService.updateSelectCanvas(
                          SelectArtboardCanvas(
                            kind: ArtboardCanvasKind.grid,
                            canvasData: gridChildKey,
                          ),
                        );
                      }
                    } else {
                      artboardCanvasService.updateSelectCanvas(
                        SelectArtboardCanvas(
                          kind: ArtboardCanvasKind.grid,
                          canvasData: gridChildKey,
                        ),
                      );
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(widget.isThumbnail
                        ? GridArtboardState.maxGridRaduis / 2
                        : artboardState.gridRadius),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(widget.isThumbnail
                            ? GridArtboardState.maxGridRaduis / 2
                            : artboardState.gridRadius),
                      ),
                      child: gridChild.wrapItem,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.isThumbnail
                          ? GridArtboardState.maxGridRaduis / 2
                          : gridArtboardState.gridRadius),
                      color: widget.isCaptureWidget
                          ? null
                          : (isGridItem
                              ? (selectedGridKey == gridChildKey
                                  ? const Color.fromARGB(150, 133, 143, 193)
                                  : Colors.transparent)
                              : null),
                      border: isGridItem &&
                              !widget.isThumbnail &&
                              gridArtboardState.borderWidth != 0
                          ? Border.all(
                              color: Color(
                                  int.parse(gridArtboardState.borderColor)),
                              width: gridArtboardState.borderWidth,
                              strokeAlign: BorderSide.strokeAlignOutside,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
    return positioned;
  }

  Positioned _buildDividerPositioned({
    required _DistanceFrom distance,
    required Widget child,
  }) {
    bool last = false;
    Positioned positioned = Positioned(
      // key: child.key,
      top: _convert(distance.top, last),
      left: _convert(distance.left, last),
      right: _convert(distance.right, last),
      bottom: _convert(distance.bottom, last),
      child: ClipRect(
        child: child,
      ),
    );
    return positioned;
  }

  /// This is a workaround for https://github.com/flutter/flutter/issues/14288
  /// The problem minimizes by avoiding the use of coordinates with
  /// decimal values.
  double _convert(double value, bool last) {
    if (widget.antiAliasingWorkaround) {
      if (last) {
        return value.roundToDouble();
      }
      return value.floorToDouble();
    }
    return value;
  }
}

/// Defines distance from edges.
class _DistanceFrom {
  double top = 0;
  double left = 0;
  double right = 0;
  double bottom = 0;

  _DistanceFrom();

  @override
  String toString() {
    return 'top = $top left = $left right = $right bottom = $bottom';
  }
}

class _InitialDrag {
  _InitialDrag(
      {required this.initialDragPos,
      required this.initialChild1Size,
      required this.initialChild2Size,
      required this.minimalChild1Size,
      required this.minimalChild2Size,
      required this.sumMinimals,
      required this.sumSizes,
      required this.child1Start,
      required this.child2End,
      required this.posLimitStart,
      required this.posLimitEnd});

  final double initialDragPos;
  final double initialChild1Size;
  final double initialChild2Size;
  final double minimalChild1Size;
  final double minimalChild2Size;
  final double sumMinimals;
  final double sumSizes;
  final double child1Start;
  final double child2End;
  final double posLimitStart;
  final double posLimitEnd;
  bool posBeforeMinimalChild1 = false;
  bool posAfterMinimalChild2 = false;
}

/// Signature for when a weight area is changed.
typedef OnWeightChange = void Function();
typedef ConfigChange = void Function(double value);

class GridArtBoardWrapItem {
  final ValueKey valueKey;
  final Widget wrapItem;

  GridArtBoardWrapItem({
    required this.valueKey,
    required this.wrapItem,
  });

  static const String _midFix = '_isThumbnail_';

  static ValueKey itemKey(int index, bool isThumbnail) {
    return ValueKey('grid_item_key_$index$_midFix$isThumbnail');
  }

  static String prefix(ValueKey valueKey) {
    return valueKey.value.split(_midFix).first;
  }

  static bool isThumbnail(ValueKey valueKey) {
    return valueKey.value.split(_midFix).last == 'true';
  }

  static ValueKey wrapItemKey(ValueKey valueKey) {
    String valueKeyValue = valueKey.value;
    List<String> splitString = valueKeyValue.split(_midFix);
    ValueKey newValueKey = ValueKey('${splitString.first}${_midFix}false');
    return newValueKey;
  }
}
