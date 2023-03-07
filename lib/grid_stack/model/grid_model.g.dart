// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grid_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GridModel _$GridModelFromJson(Map<String, dynamic> json) => GridModel(
      id: json['id'] as String,
      layout: GridLayoutModel.fromJson(json['layout'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GridModelToJson(GridModel instance) => <String, dynamic>{
      'id': instance.id,
      'layout': instance.layout,
    };
