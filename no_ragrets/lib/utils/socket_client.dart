import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  IO.Socket? socket;
  static SocketClient? _instance;

  // IMPORTANT: For physical Android device, use your computer's IP address
  // Run 'ipconfig' in Command Prompt to find your IPv4 address
  // Replace YOUR_COMPUTER_IP below with your actual IP (e.g., 192.168.1.100)
  static const String _serverUrl = 'http://YOUR_COMPUTER_IP:3000';
  // For Android emulator use: 'http://10.0.2.2:3000'
  // For iOS simulator use: 'http://localhost:3000'
  // For physical device use your computer's IP: 'http://192.168.x.x:3000'
  // For Windows desktop app use: 'http://127.0.0.1:3000'

  SocketClient._internal() {
    socket = IO.io(_serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnection': true,
      'reconnectionDelay': 1000,
      'reconnectionDelayMax': 5000,
      'reconnectionAttempts': 5,
    });
    socket!.connect();

    // Add connection event handlers for debugging
    socket!.on('connect', (_) {
      print('Socket connected: ${socket!.id}');
    });

    socket!.on('connect_error', (error) {
      print('Socket connection error: $error');
    });

    socket!.on('disconnect', (_) {
      print('Socket disconnected');
    });
  }

  static SocketClient get instance {
    _instance ??= SocketClient._internal();
    return _instance!;
  }
}
