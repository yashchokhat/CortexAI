import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/esp_claw_device.dart';
import '../services/device_discovery_service.dart';
import '../services/connection_manager.dart';
import 'esp_dashboard_page.dart';

class DeviceDiscoveryPage extends StatefulWidget {
  const DeviceDiscoveryPage({super.key});

  @override
  State<DeviceDiscoveryPage> createState() => _DeviceDiscoveryPageState();
}

class _DeviceDiscoveryPageState extends State<DeviceDiscoveryPage> {
  final DeviceDiscoveryService _discoveryService = DeviceDiscoveryService();
  final TextEditingController _ipController = TextEditingController();
  final List<EspClawDevice> _devices = [];
  StreamSubscription<EspClawDevice>? _subscription;
  bool _isScanning = false;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _discoveryService.stopDiscovery();
    _ipController.dispose();
    super.dispose();
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
      _devices.clear();
    });

    _subscription?.cancel();
    _subscription = _discoveryService.discoveredDevices.listen((device) {
      if (mounted && !_devices.any((d) => d.ip == device.ip)) {
        setState(() => _devices.add(device));
      }
    });

    _discoveryService.startDiscovery();

    // Stop scanning after 12 seconds
    Future.delayed(const Duration(seconds: 12), () {
      if (mounted) {
        _discoveryService.stopDiscovery();
        setState(() => _isScanning = false);
      }
    });
  }

  void _connectToDevice(EspClawDevice device) async {
    setState(() => _isConnecting = true);
    final success = await ConnectionManager.instance.connect(device);
    if (!mounted) return;
    setState(() => _isConnecting = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (_) => const EspDashboardPage()),
      );
    } else {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Connection Failed', style: TextStyle(color: Colors.white)),
          content: Text('Could not reach ${device.ip}', style: const TextStyle(color: Color(0xCCFFFFFF))),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      );
    }
  }

  void _connectManualIp() {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) return;
    final device = EspClawDevice(name: 'ESP-Claw', ip: ip, status: 'online');
    _connectToDevice(device);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: const CupertinoThemeData(brightness: Brightness.dark, primaryColor: Colors.white),
      child: Scaffold(
        backgroundColor: const Color(0xFF000000),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Device Discovery', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
          centerTitle: true,
          actions: [
            CupertinoButton(
              padding: const EdgeInsets.only(right: 16),
              onPressed: _isScanning ? null : _startScanning,
              child: Icon(CupertinoIcons.refresh, color: _isScanning ? const Color(0x55FFFFFF) : Colors.white, size: 20),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Scanning indicator
              if (_isScanning)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      const CupertinoActivityIndicator(color: Colors.white, radius: 12),
                      const SizedBox(height: 10),
                      Text(
                        'Scanning local network...',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                      ).animate(onPlay: (c) => c.repeat()).fadeIn(duration: 800.ms).then().fadeOut(duration: 800.ms),
                    ],
                  ),
                ),

              // Device list
              Expanded(
                child: _devices.isEmpty && !_isScanning
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(CupertinoIcons.wifi_slash, color: Color(0x55FFFFFF), size: 48),
                            const SizedBox(height: 12),
                            const Text('No devices found', style: TextStyle(color: Color(0x99FFFFFF), fontSize: 15)),
                            const SizedBox(height: 16),
                            CupertinoButton(
                              onPressed: _startScanning,
                              child: const Text('Retry', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _devices.length,
                        itemBuilder: (context, index) {
                          final device = _devices[index];
                          return _buildDeviceCard(device, index);
                        },
                      ),
              ),

              // Manual IP entry
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0x1AFFFFFF))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoTextField(
                        controller: _ipController,
                        placeholder: 'Enter IP manually (e.g. 192.168.43.120)',
                        placeholderStyle: const TextStyle(color: Color(0x55FFFFFF), fontSize: 14),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141416),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0x28FFFFFF)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: _isConnecting ? null : _connectManualIp,
                      child: _isConnecting
                          ? const CupertinoActivityIndicator(color: Colors.black)
                          : const Text('Connect', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceCard(EspClawDevice device, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C0E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x28FFFFFF)),
        boxShadow: const [BoxShadow(color: Color(0x10007AFF), blurRadius: 20, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF141416),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x22FFFFFF)),
            ),
            child: const Center(child: Icon(Icons.developer_board_rounded, color: Colors.white, size: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(device.name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: device.status == 'online' ? const Color(0xFF34C759) : const Color(0xFF666666),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${device.chip.isNotEmpty ? '${device.chip} • ' : ''}${device.ip}',
                  style: const TextStyle(color: Color(0x99FFFFFF), fontSize: 12),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            onPressed: () => _connectToDevice(device),
            child: const Text('Connect', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index * 60).ms).slideY(begin: 0.05, curve: Curves.easeOutCubic);
  }
}
