import 'package:flutter/foundation.dart';

class Player {
  String name;
  int score;

  Player({required this.name, this.score = 0});

  // Factory constructor to create a Player from a JSON object
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['name'],
      score: json['score'],
    );
  }

  // Method to convert a Player object to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'score': score,
    };
  }
}

class GameSession {
  String id;
  DateTime date;
  List<Player> players;

  GameSession({required this.id, required this.date, required this.players});

  // Factory constructor to create a GameSession from a JSON object
  factory GameSession.fromJson(Map<String, dynamic> json) {
    var playerList = json['players'] as List;
    List<Player> players = playerList.map((i) => Player.fromJson(i)).toList();

    return GameSession(
      id: json['id'],
      date: DateTime.parse(json['date']),
      players: players,
    );
  }

  // Method to convert a GameSession object to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'players': players.map((player) => player.toJson()).toList(),
    };
  }
}
