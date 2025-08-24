import 'package:flutter/material.dart';
import '../models.dart';
import '../services/storage_service.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  _RankingScreenState createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final StorageService _storageService = StorageService();
  List<Player> _rankedPlayers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRankings();
  }

  Future<void> _loadRankings() async {
    final players = await _storageService.getRanking();
    setState(() {
      _rankedPlayers = players;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Rankings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rankedPlayers.isEmpty
              ? const Center(
                  child: Text(
                    'No player data available.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _rankedPlayers.length,
                  itemBuilder: (context, index) {
                    final player = _rankedPlayers[index];
                    final rank = index + 1;
                    final scoreColor = player.score > 0
                        ? Colors.green.shade700
                        : player.score < 0
                            ? Colors.red.shade700
                            : Colors.black87;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(rank.toString()),
                        ),
                        title: Text(
                          player.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Total Buy-in: ${player.buyIn}'),
                        trailing: Text(
                          'Score: ${player.score}',
                          style: TextStyle(
                            color: scoreColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
