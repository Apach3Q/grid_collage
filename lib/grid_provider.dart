import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:grid_collage/grid_stack/model/grid_model.dart';

class GridProvider {
  static final GridProvider _instance = GridProvider._();
  GridProvider._();
  static GridProvider get instance => _instance;

  List<GridModel> grids = [];

  initialized() async {
    String jsonResult =
        await rootBundle.loadString('assets/jsons/grid_layout.json');
    List gridJsonList = json.decode(jsonResult);
    List<GridModel> gridModels = [];
    for (final gridLayout in gridJsonList) {
      GridModel layoutModel = GridModel.fromJson(gridLayout);
      gridModels.add(layoutModel);
    }
    grids = gridModels;
  }
}
