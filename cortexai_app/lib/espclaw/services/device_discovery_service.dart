import 'dart:async';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'esp_claw_api.dart';
import '../models/esp_claw_device.dart';

class DeviceDiscoveryService {
  final _controller = StreamController<EspClawDevice>.broadcast();
  Stream<EspClawDevice> get discoveredDevices => _controller.stream;

  bool _isDiscovering = false;
  MDnsClient? _mdns;

  Future<void> startDiscovery() async {
    if (_isDiscovering) return;
    _isDiscovering = true;

    _discoverMdns();
    _discoverSubnet();
  }

  void stopDiscovery() {
    _isDiscovering = false;
    _mdns?.stop();
    _mdns = null;
  }

  Future<void> _discoverMdns() async {
    _mdns = MDnsClient();
    await _mdns!.start();

    final queries = ['_esp-claw._tcp.local', '_http._tcp.local'];

    for (final q in queries) {
      if (!_isDiscovering) break;
      await for (final PtrResourceRecord ptr
          in _mdns!.lookup<PtrResourceRecord>(
            ResourceRecordQuery.serverPointer(q),
          )) {
        if (!_isDiscovering) break;
        await for (final SrvResourceRecord srv
            in _mdns!.lookup<SrvResourceRecord>(
              ResourceRecordQuery.service(ptr.domainName),
            )) {
          if (!_isDiscovering) break;
          await for (final IPAddressResourceRecord ip
              in _mdns!.lookup<IPAddressResourceRecord>(
                ResourceRecordQuery.addressIPv4(srv.target),
              )) {
            if (!_isDiscovering) break;
            final ipStr = ip.address.address;
            _checkAndAddDevice(ipStr, srv.port, ptr.domainName);
          }
        }
      }
    }
  }

  Future<void> _discoverSubnet() async {
    final List<String> subnetsToScan = ['192.168.43.', '192.168.1.'];

    try {
      final info = NetworkInfo();
      final wifiIP = await info.getWifiIP();
      if (wifiIP != null) {
        final parts = wifiIP.split('.');
        if (parts.length == 4) {
          final currentSubnet = '${parts[0]}.${parts[1]}.${parts[2]}.';
          if (!subnetsToScan.contains(currentSubnet)) {
            subnetsToScan.insert(0, currentSubnet);
          }
        }
      }
    } catch (_) {
      // Ignore network info errors
    }

    for (final baseIp in subnetsToScan) {
      if (!_isDiscovering) break;
      final futures = <Future>[];
      for (int i = 1; i < 255; i++) {
        if (!_isDiscovering) break;
        final ip = '$baseIp$i';
        futures.add(_checkAndAddDevice(ip, 80, 'ESP-Claw ($ip)'));
        if (futures.length >= 20) {
          await Future.wait(futures);
          futures.clear();
        }
      }
      if (futures.isNotEmpty) {
        await Future.wait(futures);
      }
    }
  }

  Future<void> _checkAndAddDevice(String ip, int port, String name) async {
    try {
      final api = EspClawApi(ip: ip);
      final isHealthy = await api.healthCheck();
      if (isHealthy) {
        final statusMap = await api.getStatus();
        final device = EspClawDevice(
          name: statusMap['deviceName']?.toString() ?? name,
          ip: ip,
          httpPort: port,
          chip: statusMap['chipInfo']?.toString() ?? '',
          status: 'online',
        );
        _controller.add(device);
      }
    } catch (_) {
      // Ignore errors
    }
  }
}
