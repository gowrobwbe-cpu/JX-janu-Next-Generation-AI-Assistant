import 'package:web_socket_channel/web_socket_channel.dart';

class ESP32RobotController {
  WebSocketChannel? _channel;
  bool isConnected = false;

  void connectToRobot(String robotIp) {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://$robotIp:81'),
      );
      isConnected = true;
    } catch (e) {
      isConnected = false;
    }
  }

  void moveForward() => _send('FORWARD');
  void moveBackward() => _send('BACKWARD');
  void turnLeft() => _send('LEFT');
  void turnRight() => _send('RIGHT');
  void stop() => _send('STOP');

  void _send(String command) {
    if (isConnected && _channel != null) {
      _channel!.sink.add(command);
    }
  }

  void disconnect() {
    _channel?.sink.close();
    isConnected = false;
  }
}
