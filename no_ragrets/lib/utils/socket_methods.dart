import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:no_ragrets/providers/client_state_provider.dart';
import 'package:no_ragrets/providers/game_state_provider.dart';
import 'package:no_ragrets/utils/socket_client.dart';

class SocketMethods {
  final _socketClient = SocketClient.instance.socket!;
  bool _isPlaying = false;

  // create game
  createGame(String nickname) {
    if (nickname.isNotEmpty) {
      _socketClient.emit('create-game', {'nickname': nickname});
    }
  }

  // join game
  joinGame(String gameId, String nickname) {
    if (nickname.isNotEmpty && gameId.isNotEmpty) {
      _socketClient.emit('join-game', {'nickname': nickname, 'gameId': gameId});
    }
  }

  sendUserInput(String value, String gameID) {
    _socketClient.emit('userInput', {'userInput': value, 'gameID': gameID});
  }

  // listeners
  updateGameListener(BuildContext context) {
    _socketClient.on('updateGame', (data) {
      if (data == null || data is! Map) return;

      Provider.of<GameStateProvider>(
        context,
        listen: false,
      ).updateGameState(
        id: data['_id'] ?? '',
        players: data['players'] ?? [],
        isJoin: data['isJoin'] ?? false,
        words: data['words'] ?? [],
        isOver: data['isOver'] ?? false,
      );

      if (data['_id'] != null && data['_id'].toString().isNotEmpty && !_isPlaying) {
        Navigator.pushNamed(context, '/game-screen');
        _isPlaying = true;
      }
    });
  }

  startTimer(String playerId, String gameID) {
    _socketClient.emit('timer', {'playerId': playerId, 'gameID': gameID});
  }

  notCorrectGameListener(BuildContext context) {
    _socketClient.on(
      'notCorrectGame',
      (data) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(data?.toString() ?? 'Error'))),
    );
  }

  updateTimer(BuildContext context) {
    final clientStateProvider = Provider.of<ClientStateProvider>(
      context,
      listen: false,
    );
    _socketClient.on('timer', (data) {
      if (data != null) {
        clientStateProvider.setClientState(data);
      }
    });
  }

  updateGame(BuildContext context) {
    _socketClient.on('updateGame', (data) {
      if (data == null || data is! Map) return;

      Provider.of<GameStateProvider>(
        context,
        listen: false,
      ).updateGameState(
        id: data['_id'] ?? '',
        players: data['players'] ?? [],
        isJoin: data['isJoin'] ?? false,
        words: data['words'] ?? [],
        isOver: data['isOver'] ?? false,
      );
    });
  }

  gameFinishedListener() {
    _socketClient.on('done', (data) => _socketClient.off('timer'));
  }
}
