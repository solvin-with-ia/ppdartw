import 'package:flutter/material.dart';

@immutable
class VoteModel {
  // Empty string if not voted
  // Opcional: fecha/hora del voto, comentario, etc.

  const VoteModel({required this.userId, this.cardId = ''});

  factory VoteModel.fromJson(Map<String, dynamic> json) => VoteModel(
    userId: json['userId'] as String,
    cardId: json['cardId'] as String? ?? '',
  );
  final String userId;
  final String cardId;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'userId': userId,
    'cardId': cardId,
  };

  VoteModel copyWith({String? userId, String? cardId}) {
    return VoteModel(
      userId: userId ?? this.userId,
      cardId: cardId ?? this.cardId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoteModel &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          cardId == other.cardId;

  @override
  int get hashCode => userId.hashCode ^ cardId.hashCode;
}
