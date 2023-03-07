import 'package:json_annotation/json_annotation.dart';

import 'grid_layout_model.dart';

part 'grid_model.g.dart';

@JsonSerializable()
class GridModel {
  final String id;
  final GridLayoutModel layout;

  GridModel({
    required this.id,
    required this.layout,
  });

  factory GridModel.fromJson(Map<String, dynamic> json) =>
      _$GridModelFromJson(json);
  Map<String, dynamic> toJson() => _$GridModelToJson(this);
}
