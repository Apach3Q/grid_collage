import 'package:json_annotation/json_annotation.dart';

import 'grid_child_layout_model.dart';

part 'grid_layout_model.g.dart';

@JsonSerializable()
class GridLayoutModel {
  final double weight;
  final GridChildLayoutModel? layout;

  GridLayoutModel({
    required this.weight,
    this.layout,
  });

  factory GridLayoutModel.fromJson(Map<String, dynamic> json) =>
      _$GridLayoutModelFromJson(json);
  Map<String, dynamic> toJson() => _$GridLayoutModelToJson(this);
}
