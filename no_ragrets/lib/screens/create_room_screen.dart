import 'package:flutter/material.dart';
import 'package:no_ragrets/utils/socket_client.dart';
import 'package:no_ragrets/utils/socket_methods.dart';
import 'package:no_ragrets/widgets/custom_button.dart';
import 'package:no_ragrets/widgets/custom_text_field.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({Key? key}) : super(key: key);

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController _nameController = TextEditingController();
  final SocketMethods _socketMethods = SocketMethods();
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _socketMethods.updateGameListener(context);
    _socketMethods.notCorrectGameListener(context);
    _checkConnection();
  }

  void _checkConnection() {
    final socket = SocketClient.instance.socket;
    setState(() {
      _isConnected = socket?.connected ?? false;
    });

    // Listen for connection changes
    socket?.on('connect', (_) {
      if (mounted) {
        setState(() {
          _isConnected = true;
        });
      }
    });

    socket?.on('disconnect', (_) {
      if (mounted) {
        setState(() {
          _isConnected = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Create Room', style: TextStyle(fontSize: 30)),
                const SizedBox(height: 10),
                // Connection status indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isConnected ? Icons.wifi : Icons.wifi_off,
                      color: _isConnected ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isConnected ? 'Connected to server' : 'Not connected to server',
                      style: TextStyle(
                        color: _isConnected ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.08),
                CustomTextField(
                  controller: _nameController,
                  hintText: 'Enter your nickname',
                ),
                const SizedBox(height: 30),
                CustomButton(
                  text: 'Create',
                  onTap: () {
                    if (!_isConnected) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Not connected to server. Please check if the server is running.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    if (_nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a nickname')),
                      );
                      return;
                    }
                    _socketMethods.createGame(_nameController.text.trim());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
