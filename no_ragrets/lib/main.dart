import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:no_ragrets/providers/client_state_provider.dart';
import 'package:no_ragrets/providers/game_state_provider.dart';
import 'package:no_ragrets/screens/create_room_screen.dart';
import 'package:no_ragrets/screens/game_screen.dart';
import 'package:no_ragrets/screens/home_screen.dart';
import 'package:no_ragrets/screens/join_room_screen.dart';
import 'package:no_ragrets/utils/socket_client.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize socket connection at app startup
  SocketClient.instance;
  runApp(const NoRagrets());
}

class NoRagrets extends StatelessWidget {
  const NoRagrets({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GameStateProvider()),
        ChangeNotifierProvider(create: (context) => ClientStateProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Typeracer Tutorial',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/create-room': (context) => const CreateRoomScreen(),
          '/join-room': (context) => const JoinRoomScreen(),
          '/game-screen': (context) => const GameScreen(),
        },
      ),
    );
  }
}
