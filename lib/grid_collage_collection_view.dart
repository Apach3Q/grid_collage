import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grid_collage/gradient_border_view.dart';
import 'package:grid_collage/grid_collage_service.dart';
import 'package:grid_collage/grid_provider.dart';
import 'package:grid_collage/grid_stack/grid_art_board.dart';
import 'package:grid_collage/grid_stack/model/grid_model.dart';
import 'dart:ui' as ui;

class GridCollageCollectionView extends StatelessWidget {
  const GridCollageCollectionView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: ScreenUtil().statusBarHeight + 44.w,
        bottom: ScreenUtil().bottomBarHeight + 44.w,
      ),
      // color: Colors.red,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
            ),
            sliver: Consumer(
              builder: (context, ref, child) {
                final gridCollageState = ref.watch(gridCollageProvider);
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 6.w,
                    crossAxisSpacing: 4.w,
                    childAspectRatio: 1.0,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    childCount: gridCollageState.gridItems.length,
                    (BuildContext context, int index) {
                      final gridItem = gridCollageState.gridItems[index];
                      return GridCollageGridsViewItem(
                        index: index,
                        gridModel: gridItem,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GridCollageGridsViewItem extends ConsumerStatefulWidget {
  final int index;
  final GridModel gridModel;

  const GridCollageGridsViewItem({
    super.key,
    required this.index,
    required this.gridModel,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GridCollageGridsViewItemState();
}

class _GridCollageGridsViewItemState
    extends ConsumerState<GridCollageGridsViewItem>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer(
      builder: (context, ref, child) {
        final gridCollageState = ref.watch(gridCollageProvider);
        return GradientBorderView(
          visible: widget.index == gridCollageState.selectGridIndex,
          radius: 10,
          margin: 1.5,
          child: GestureDetector(
            onTap: () {
              final gridCollageService = ref.read(gridCollageProvider.notifier);
              gridCollageService.updateSelectGrid(widget.index);
            },
            child: FittedBox(
              child: AbsorbPointer(
                child: Container(
                  width: 1242.0,
                  height: 1242.0,
                  child: GridArtBoard(
                    gridModel: widget.gridModel,
                    isThumbnail: true,
                    isCaptureWidget: false,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
