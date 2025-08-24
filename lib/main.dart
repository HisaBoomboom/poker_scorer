import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'models.dart';
import 'screens/score_input_screen.dart';
import 'services/storage_service.dart';

void main() {
  runApp(const PokerScoreTrackerApp());
}

class PokerScoreTrackerApp extends StatelessWidget {
  const PokerScoreTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poker Score Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StorageService _storageService = StorageService();
  final Uuid _uuid = const Uuid();
  List<GameSession> _gameSessions = [];

  @override
  void initState() {
    super.initState();
    _loadGameSessions();
  }

  Future<void> _loadGameSessions() async {
    final sessions = await _storageService.getGameSessions();
    setState(() {
      _gameSessions = sessions;
    });
  }

  Future<void> _navigateToScoreInputScreen() async {
    // Navigate to the score input screen and wait for a result.
    final List<Player>? newPlayers = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScoreInputScreen()),
    );

    // If the user saved a new game, create a session and save it.
    if (newPlayers != null && newPlayers.isNotEmpty) {
      final newSession = GameSession(
        id: _uuid.v4(),
        date: DateTime.now(),
        players: newPlayers,
      );

      setState(() {
        _gameSessions.insert(0, newSession); // Add to the top of the list
      });

      await _storageService.saveGameSessions(_gameSessions);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poker Score Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _gameSessions.isEmpty
          ? const Center(
              child: Text(
                'No games saved yet.\nPress the "+" button to start a new game.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _gameSessions.length,
              itemBuilder: (context, index) {
                final session = _gameSessions[index];
                // Format the date nicely
                final formattedDate = DateFormat.yMMMd().add_jm().format(session.date);
                final playersSummary = session.players.map((p) => '${p.name}: ${p.score}').join(', ');

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  child: ListTile(
                    title: Text(
                      'Game on $formattedDate',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(playersSummary),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToScoreInputScreen,
        tooltip: 'New Game',
        child: const Icon(Icons.add),
      ),
    );
  }
}
