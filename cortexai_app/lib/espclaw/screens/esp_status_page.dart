import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../services/connection_manager.dart';

class EspStatusPage extends StatefulWidget {
  const EspStatusPage({Key? key}) : super(key: key);

  @override
  State<EspStatusPage> createState() => _EspStatusPageState();
}

class _EspStatusPageState extends State<EspStatusPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _statusData;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    setState(() => _isLoading = true);
    final client = ConnectionManager.instance.api;
    if (client != null) {
      try {
        final status = await client.getStatus();
        if (mounted) {
          setState(() {
            _statusData = status;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: const CupertinoThemeData(brightness: Brightness.dark),
      child: Scaffold(
        backgroundColor: const Color(0xFF000000),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'System Status',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              fontFamily: '.SF Pro Text',
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _fetchStatus,
          color: Colors.white,
          backgroundColor: const Color(0xFF1C1C1E),
          child: _isLoading && _statusData == null
              ? const Center(child: CupertinoActivityIndicator(radius: 16))
              : _statusData == null
              ? ListView(
                  children: const [
                    SizedBox(height: 100),
                    Center(
                      child: Text(
                        'Failed to load status',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildStatusCard(
                      title: 'Network',
                      icon: CupertinoIcons.wifi,
                      children: [
                        _buildInfoRow(
                          'IP Address',
                          _statusData!['ip']?.toString() ?? '0.0.0.0',
                        ),
                        _buildInfoRow(
                          'Wi-Fi Mode',
                          (_statusData!['wifi_mode']?.toString() ?? 'unknown')
                              .toUpperCase(),
                        ),
                        _buildInfoRow(
                          'Status',
                          _statusData!['wifi_connected'] == true
                              ? 'Connected'
                              : 'Disconnected',
                          valueColor: _statusData!['wifi_connected'] == true
                              ? CupertinoColors.activeGreen
                              : CupertinoColors.destructiveRed,
                        ),
                      ],
                    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05),
                    const SizedBox(height: 16),
                    _buildStatusCard(
                          title: 'Access Point',
                          icon: CupertinoIcons.antenna_radiowaves_left_right,
                          children: [
                            _buildInfoRow(
                              'AP Active',
                              _statusData!['ap_active'] == true ? 'Yes' : 'No',
                              valueColor: _statusData!['ap_active'] == true
                                  ? CupertinoColors.activeGreen
                                  : Colors.white,
                            ),
                            _buildInfoRow(
                              'AP SSID',
                              _statusData!['ap_ssid']?.toString() ?? 'N/A',
                            ),
                            _buildInfoRow(
                              'AP IP Address',
                              _statusData!['ap_ip']?.toString() ?? 'N/A',
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 100.ms)
                        .slideY(begin: 0.05),
                    const SizedBox(height: 16),
                    _buildStatusCard(
                          title: 'System',
                          icon: CupertinoIcons.device_laptop,
                          children: [
                            _buildInfoRow(
                              'Storage Path',
                              _statusData!['storage_base_path']?.toString() ??
                                  '/fatfs',
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 200.ms)
                        .slideY(begin: 0.05),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C0E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x28FFFFFF)),
        boxShadow: const [BoxShadow(color: Color(0x10007AFF), blurRadius: 20)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0x99FFFFFF), fontSize: 15),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
