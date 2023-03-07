import 'package:json_annotation/json_annotation.dart';

import 'grid_layout_model.dart';

part 'grid_child_layout_model.g.dart';

@JsonSerializable()
class GridChildLayoutModel {
  final String axis;
  final List<GridLayoutModel> children;

  GridChildLayoutModel({
    required this.axis,
    required this.children,
  });

  factory GridChildLayoutModel.fromJson(Map<String, dynamic> json) =>
      _$GridChildLayoutModelFromJson(json);
  Map<String, dynamic> toJson() => _$GridChildLayoutModelToJson(this);
}
