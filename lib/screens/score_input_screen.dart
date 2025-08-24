import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models.dart';

class ScoreInputScreen extends StatefulWidget {
  const ScoreInputScreen({super.key});

  @override
  _ScoreInputScreenState createState() => _ScoreInputScreenState();
}

class _ScoreInputScreenState extends State<ScoreInputScreen> {
  final List<Player> _players = [];
  final _playerNameController = TextEditingController();
  final Map<String, TextEditingController> _scoreControllers = {};

  int _totalScore = 0;

  void _addPlayer() {
    final name = _playerNameController.text.trim();
    if (name.isNotEmpty && !_players.any((p) => p.name == name)) {
      setState(() {
        final newPlayer = Player(name: name);
        _players.add(newPlayer);
        _scoreControllers[name] = TextEditingController();
        _playerNameController.clear();
      });
      _calculateTotal();
    }
  }

  void _removePlayer(int index) {
    setState(() {
      final player = _players.removeAt(index);
      _scoreControllers.remove(player.name)?.dispose();
    });
    _calculateTotal();
  }

  void _calculateTotal() {
    int sum = 0;
    for (var player in _players) {
      sum += player.score;
    }
    setState(() {
      _totalScore = sum;
    });
  }

  void _updateScore(Player player, String value) {
    player.score = int.tryParse(value) ?? 0;
    _calculateTotal();
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    _scoreControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSaveDisabled = _totalScore != 0 || _players.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Game Session'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Game',
            onPressed: isSaveDisabled
                ? null
                : () {
                    // Pop and return the list of players
                    Navigator.of(context).pop(_players);
                  },
          ),
        ],
      ),
      body: Column(
        children: [
          // Player input area
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _playerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Player Name',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addPlayer(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addPlayer,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          // Players list
          Expanded(
            child: ListView.builder(
              itemCount: _players.length,
              itemBuilder: (context, index) {
                final player = _players[index];
                return ListTile(
                  leading: CircleAvatar(child: Text((index + 1).toString())),
                  title: Text(player.name, style: const TextStyle(fontSize: 18)),
                  trailing: SizedBox(
                    width: 150,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _scoreControllers[player.name],
                            decoration: const InputDecoration(
                              labelText: 'Score',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(signed: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9]*')),
                            ],
                            onChanged: (value) => _updateScore(player, value),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => _removePlayer(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Total score footer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _totalScore == 0 ? Colors.green.shade100 : Colors.red.shade100,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Center(
              child: Text(
                'Total Score: $_totalScore',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _totalScore == 0 ? Colors.green.shade800 : Colors.red.shade800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
