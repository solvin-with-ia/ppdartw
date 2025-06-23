import 'package:flutter/material.dart' hide DateUtils;
import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../../domain/enums/role.dart';
import 'card_model.dart';
import 'model_utils.dart';
import 'vote_model.dart';

@immutable
class GameModel {
  // Agregado para el rol del usuario
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
    this.isNew = false,
    this.currentStory,
    this.stories = const <String>[],
    this.revealTimeout,
    this.role = Role.jugador,
  });

  factory GameModel.empty() => GameModel(
    id: '',
    name: '',
    admin: const UserModel(
      id: '',
      displayName: '',
      email: '',
      photoUrl: '',
      jwt: <String, dynamic>{},
    ),
    spectators: const <UserModel>[],
    players: const <UserModel>[],
    votes: const <VoteModel>[],
    isActive: false,
    createdAt: DateTime(1970),
    deck: const <CardModel>[],
    isNew: true,
  );
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
  final Role? role;
  final bool isNew;
  // ...
  GameModel copyWith({
    String? id,
    String? name,
    UserModel? admin,
    List<UserModel>? spectators,
    List<UserModel>? players,
    List<VoteModel>? votes,
    bool? isActive,
    DateTime? createdAt,
    List<CardModel>? deck,
    DateTime? finishedAt,
    bool? isNew,
    Role? role,
  }) {
    return GameModel(
      id: id ?? this.id,
      name: name ?? this.name,
      admin: admin ?? this.admin,
      spectators: spectators ?? this.spectators,
      players: players ?? this.players,
      votes: votes ?? this.votes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      deck: deck ?? this.deck,
      finishedAt: finishedAt ?? this.finishedAt,
      isNew: isNew ?? this.isNew,
      role: role ?? this.role,
    );
  }

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

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'admin': admin.toJson(),
      'spectators': spectators.map((UserModel u) => u.toJson()).toList(),
      'players': players.map((UserModel u) => u.toJson()).toList(),
      'votes': votes.map((VoteModel v) => v.toJson()).toList(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'finishedAt': finishedAt?.toIso8601String(),
      'currentStory': currentStory,
      'stories': stories,
      'deck': deck.map((CardModel c) => c.toJson()).toList(),
      'revealTimeout': revealTimeout,
    };
  }
}
