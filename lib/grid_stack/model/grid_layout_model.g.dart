// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grid_layout_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GridLayoutModel _$GridLayoutModelFromJson(Map<String, dynamic> json) =>
    GridLayoutModel(
      weight: (json['weight'] as num).toDouble(),
      layout: json['layout'] == null
          ? null
          : GridChildLayoutModel.fromJson(
              json['layout'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GridLayoutModelToJson(GridLayoutModel instance) =>
    <String, dynamic>{
      'weight': instance.weight,
      'layout': instance.layout,
    };
