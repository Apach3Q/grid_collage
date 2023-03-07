// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grid_child_layout_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GridChildLayoutModel _$GridChildLayoutModelFromJson(
        Map<String, dynamic> json) =>
    GridChildLayoutModel(
      axis: json['axis'] as String,
      children: (json['children'] as List<dynamic>)
          .map((e) => GridLayoutModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GridChildLayoutModelToJson(
        GridChildLayoutModel instance) =>
    <String, dynamic>{
      'axis': instance.axis,
      'children': instance.children,
    };
