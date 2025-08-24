import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models.dart';

class ScoreInputScreen extends StatefulWidget {
  final GameSession? initialSession;

  const ScoreInputScreen({super.key, this.initialSession});

  @override
  _ScoreInputScreenState createState() => _ScoreInputScreenState();
}

class _ScoreInputScreenState extends State<ScoreInputScreen> {
  final List<Player> _players = [];
  final _playerNameController = TextEditingController();
  final Map<String, TextEditingController> _stackControllers = {};
  final Map<String, TextEditingController> _buyInControllers = {};

  int _totalStack = 0;
  int _totalBuyIn = 0;
  int _totalScore = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialSession != null) {
      final sessionCopy = widget.initialSession!.copyWith();
      for (var player in sessionCopy.players) {
        _players.add(player);
        _stackControllers[player.name] =
            TextEditingController(text: player.stack.toString());
        _buyInControllers[player.name] =
            TextEditingController(text: player.buyIn.toString());
      }
      _calculateTotals();
    }
  }

  void _addPlayer() {
    final name = _playerNameController.text.trim();
    if (name.isNotEmpty && !_players.any((p) => p.name == name)) {
      setState(() {
        final newPlayer = Player(name: name);
        _players.add(newPlayer);
        _stackControllers[name] = TextEditingController();
        _buyInControllers[name] = TextEditingController();
        _playerNameController.clear();
      });
      _calculateTotals();
    }
  }

  void _removePlayer(int index) {
    setState(() {
      final player = _players.removeAt(index);
      _stackControllers.remove(player.name)?.dispose();
      _buyInControllers.remove(player.name)?.dispose();
    });
    _calculateTotals();
  }

  void _calculateTotals() {
    int stackSum = 0;
    int buyInSum = 0;
    int scoreSum = 0;
    for (var player in _players) {
      stackSum += player.stack;
      buyInSum += player.buyIn;
      scoreSum += player.score;
    }
    setState(() {
      _totalStack = stackSum;
      _totalBuyIn = buyInSum;
      _totalScore = scoreSum;
    });
  }

  void _updateStack(Player player, String value) {
    player.stack = int.tryParse(value) ?? 0;
    _calculateTotals();
    setState(() {}); // To rebuild and update the score display
  }

  void _updateBuyIn(Player player, String value) {
    player.buyIn = int.tryParse(value) ?? 0;
    _calculateTotals();
    setState(() {}); // To rebuild and update the score display
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    _stackControllers.values.forEach((controller) => controller.dispose());
    _buyInControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSaveDisabled = _players.isEmpty;
    final bool isEditing = widget.initialSession != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Game Session' : 'New Game Session'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Game',
            onPressed: isSaveDisabled
                ? null
                : () {
                    Navigator.of(context).pop(_players);
                  },
          ),
        ],
      ),
      body: Column(
        children: [
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
          Expanded(
            child: ListView.builder(
              itemCount: _players.length,
              itemBuilder: (context, index) {
                final player = _players[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          CircleAvatar(child: Text((index + 1).toString())),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Text(player.name, style: const TextStyle(fontSize: 18)),
                          ),
                          Expanded(
                            flex: 4,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildTextField(
                                    controller: _stackControllers[player.name]!,
                                    label: 'Stack',
                                    onChanged: (value) =>
                                        _updateStack(player, value),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('-', style: TextStyle(fontSize: 20)),
                                  const SizedBox(width: 8),
                                  _buildTextField(
                                    controller: _buyInControllers[player.name]!,
                                    label: 'Buy-in',
                                    onChanged: (value) =>
                                        _updateBuyIn(player, value),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('=', style: TextStyle(fontSize: 20)),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 60,
                                    child: Text(
                                      player.score.toString(),
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => _removePlayer(index),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: _totalScore == 0 ? Colors.green.shade100 : Colors.red.shade100,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Center(
              child: Column(
                children: [
                  Text(
                    'Totals',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTotalText('Stack', _totalStack),
                      _buildTotalText('Buy-in', _totalBuyIn),
                      _buildTotalText('Score', _totalScore, isScore: true),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required ValueChanged<String> onChanged,
  }) {
    return SizedBox(
      width: 80,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        ),
        keyboardType: const TextInputType.numberWithOptions(signed: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9]*'))],
        onChanged: onChanged,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTotalText(String label, int value, {bool isScore = false}) {
    final Color color;
    if (isScore) {
      color = value == 0 ? Colors.green.shade800 : Colors.red.shade800;
    } else {
      color = Colors.black87;
    }

    return Text(
      '$label: $value',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}
