import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models.dart';

class StorageService {
  static const String _sessionsKey = 'game_sessions';

  // Save a list of game sessions to shared_preferences
  Future<void> saveGameSessions(List<GameSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    // Convert the list of GameSession objects to a list of maps, then encode to a JSON string
    List<Map<String, dynamic>> sessionsJson =
        sessions.map((session) => session.toJson()).toList();
    await prefs.setString(_sessionsKey, json.encode(sessionsJson));
  }

  // Retrieve a list of game sessions from shared_preferences
  Future<List<GameSession>> getGameSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? sessionsString = prefs.getString(_sessionsKey);

    if (sessionsString == null || sessionsString.isEmpty) {
      return [];
    }

    // Decode the JSON string to a list of maps, then create a list of GameSession objects
    try {
      List<dynamic> sessionsJson = json.decode(sessionsString);
      return sessionsJson
          .map((json) => GameSession.fromJson(json))
          .toList();
    } catch (e) {
      // If decoding fails, return an empty list to prevent app crash
      print('Error decoding game sessions: $e');
      return [];
    }
  }
}
