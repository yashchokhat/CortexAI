import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';

class EspClawChat {
  final String ip;
  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;

  EspClawChat({required this.ip});

  bool get isConnected {
    return _channel != null;
  }

  void connect({
    required Function(dynamic data) onMessage,
    Function(Object error)? onError,
    Function()? onDisconnected,
  }) {
    final url = 'ws://$ip/ws/webim';

    _channel = WebSocketChannel.connect(Uri.parse(url));

    // Send hello message to match vertex-agent frontend
    _channel!.sink.add(jsonEncode({'type': 'hello', 'chat_id': 'default'}));

    // Heartbeat ping every 2 seconds
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_channel != null) {
        _channel!.sink.add(jsonEncode({'type': 'ping'}));
      } else {
        timer.cancel();
      }
    });

    _channel!.stream.listen(
      onMessage,
      onError: (error) {
        onError?.call(error);
      },
      onDone: () {
        _channel = null;
        _heartbeatTimer?.cancel();
        onDisconnected?.call();
      },
    );
  }

  void send(Map<String, dynamic> data) {
    final channel = _channel;
    if (channel == null) {
      throw Exception('ESP-Claw is not connected');
    }
    channel.sink.add(jsonEncode(data));
  }

  void close() {
    _heartbeatTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
  }
}
