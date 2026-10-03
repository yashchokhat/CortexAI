import 'dart:async';
import '../models/esp_claw_device.dart';
import 'esp_claw_api.dart';

class ConnectionManager {
  static final ConnectionManager _instance = ConnectionManager._internal();
  factory ConnectionManager() => _instance;
  static ConnectionManager get instance => _instance;
  ConnectionManager._internal();

  EspClawDevice? _selectedDevice;
  EspClawDevice? get selectedDevice => _selectedDevice;

  EspClawApi? _api;
  EspClawApi? get api => _api;

  final _connectionController = StreamController<bool>.broadcast();
  Stream<bool> get isConnected => _connectionController.stream;

  Future<bool> connect(EspClawDevice device) async {
    _selectedDevice = device;
    _api = EspClawApi(ip: device.ip);

    final healthy = await _api!.healthCheck();
    if (healthy) {
      _connectionController.add(true);
      return true;
    } else {
      _connectionController.add(false);
      _selectedDevice = null;
      _api = null;
      return false;
    }
  }

  void disconnect() {
    _selectedDevice = null;
    _api = null;
    _connectionController.add(false);
  }
}
