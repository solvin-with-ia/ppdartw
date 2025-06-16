import 'package:flutter/material.dart' hide DateUtils;
import 'package:jocaagura_domain/jocaagura_domain.dart';

import 'card_model.dart';
import 'model_utils.dart';
import 'vote_model.dart';

@immutable
class GameModel {
  const GameModel({
    required this.id,
    required this.name,
    required this.admin,
    required this.spectators,
    required this.players,
    required this.votes,
    required this.isActive,
    required this.createdAt,
    required this.deck,
    this.finishedAt,
    this.currentStory,
    this.stories = const <String>[],
    this.revealTimeout,
  });
  factory GameModel.fromJson(Map<String, dynamic> json) => GameModel(
    id: json['id'] as String,
    name: json['name'] as String,
    admin: UserModel.fromJson(json['admin'] as Map<String, dynamic>),
    spectators: convertJsonToModelList<UserModel>(
      json['spectators'],
      UserModel.fromJson,
    ),
    players: convertJsonToModelList<UserModel>(
      json['players'],
      UserModel.fromJson,
    ),
    votes: convertJsonToModelList<VoteModel>(json['votes'], VoteModel.fromJson),
    isActive: Utils.getBoolFromDynamic(json['isActive']),
    createdAt: DateTime.parse(json['createdAt'] as String),
    finishedAt: DateUtils.dateTimeFromDynamic(json['finishedAt']),
    currentStory: Utils.getStringFromDynamic(json['currentStory']),
    stories: (json['stories'] is List)
        ? List<String>.from(json['stories'] as List<String>)
        : Utils.convertJsonToList(json['stories']?.toString() ?? ''),
    deck: convertJsonToModelList<CardModel>(json['deck'], CardModel.fromJson),
    revealTimeout: json['revealTimeout'] as int?,
  );
  final String id;
  final String name;
  final UserModel admin;
  final List<VoteModel> votes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? finishedAt;
  final String? currentStory;
  final List<UserModel> spectators;
  final List<UserModel> players;
  final List<String> stories;
  final List<CardModel> deck;
  final int? revealTimeout;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'admin': admin.toJson(),
    'spectators': modelListToJson<UserModel>(
      spectators,
      (UserModel u) => u.toJson(),
    ),
    'players': modelListToJson<UserModel>(players, (UserModel u) => u.toJson()),
    'votes': modelListToJson<VoteModel>(votes, (VoteModel v) => v.toJson()),
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'finishedAt': finishedAt?.toIso8601String(),
    'currentStory': currentStory,
    'stories': stories,

    'deck': modelListToJson<CardModel>(deck, (CardModel c) => c.toJson()),
    'revealTimeout': revealTimeout,
  };
}
