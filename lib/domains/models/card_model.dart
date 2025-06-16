import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

@immutable
class CardModel {
  const CardModel({
    required this.id,
    required this.display,
    required this.value,
    required this.description,
    this.isSpecial = false,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) => CardModel(
    id: Utils.getStringFromDynamic(json['id']),
    display: Utils.getStringFromDynamic(json['display']),
    value: Utils.getIntegerFromDynamic(json['value']),
    description: Utils.getStringFromDynamic(json['description']),
    isSpecial: Utils.getBoolFromDynamic(json['isSpecial']),
  );
  final String id;
  final String display;
  final int value;
  final String description;
  final bool isSpecial;

  CardModel copyWith({
    String? id,
    String? display,
    int? value,
    String? description,
    bool? isSpecial,
  }) {
    return CardModel(
      id: id ?? this.id,
      display: display ?? this.display,
      value: value ?? this.value,
      description: description ?? this.description,
      isSpecial: isSpecial ?? this.isSpecial,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'display': display,
    'value': value,
    'description': description,
    'isSpecial': isSpecial,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
