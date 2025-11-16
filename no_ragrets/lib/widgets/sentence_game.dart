import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:no_ragrets/providers/game_state_provider.dart';
import 'package:no_ragrets/utils/socket_client.dart';
import 'package:no_ragrets/utils/socket_methods.dart';
import 'package:no_ragrets/widgets/scoreboard.dart';

class SentenceGame extends StatefulWidget {
  const SentenceGame({Key? key}) : super(key: key);

  @override
  State<SentenceGame> createState() => _SentenceGameState();
}

class _SentenceGameState extends State<SentenceGame> {
  Map<String, dynamic>? playerMe;
  final SocketMethods _socketMethods = SocketMethods();

  @override
  void initState() {
    super.initState();
    _socketMethods.updateGame(context);
  }

  findPlayerMe(GameStateProvider game) {
    game.gameState['players'].forEach((player) {
      if (player['socketID'] == SocketClient.instance.socket!.id) {
        playerMe = Map<String, dynamic>.from(player);
      }
    });
  }

  Widget getTypedWords(List words, Map<String, dynamic> player) {
    int currentIndex = player['currentWordIndex'] ?? 0;
    if (currentIndex > words.length) currentIndex = words.length;
    var tempWords = words.sublist(0, currentIndex);
    String typedWord = tempWords.join(' ');
    return Text(
      typedWord,
      style: const TextStyle(
        color: Color.fromRGBO(52, 235, 119, 1),
        fontSize: 30,
      ),
    );
  }

  Widget getCurrentWord(List words, Map<String, dynamic> player) {
    int currentIndex = player['currentWordIndex'] ?? 0;
    if (currentIndex >= words.length) {
      return const Text('');
    }
    return Text(
      words[currentIndex],
      style: const TextStyle(
        decoration: TextDecoration.underline,
        fontSize: 30,
      ),
    );
  }

  Widget getWordsToBeTyped(List words, Map<String, dynamic> player) {
    int currentIndex = player['currentWordIndex'] ?? 0;
    if (currentIndex + 1 >= words.length) {
      return const Text('');
    }
    var tempWords = words.sublist(currentIndex + 1, words.length);
    String wordstoBeTyped = tempWords.join(' ');
    return Text(wordstoBeTyped, style: const TextStyle(fontSize: 30));
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameStateProvider>(context);
    findPlayerMe(game);

    if (playerMe == null) {
      return const Center(child: CircularProgressIndicator());
    }

    int currentWordIndex = playerMe!['currentWordIndex'] ?? 0;
    if (game.gameState['words'].length > currentWordIndex) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Wrap(
          textDirection: TextDirection.ltr,
          children: [
            getTypedWords(game.gameState['words'], playerMe!),
            getCurrentWord(game.gameState['words'], playerMe!),
            getWordsToBeTyped(game.gameState['words'], playerMe!),
          ],
        ),
      );
    }
    return const Scoreboard();
  }
}
