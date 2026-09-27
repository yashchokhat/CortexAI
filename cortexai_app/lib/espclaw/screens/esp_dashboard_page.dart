import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../services/connection_manager.dart';
import 'esp_chat_page.dart';
import 'esp_status_page.dart';
import 'esp_capabilities_page.dart';
import 'esp_files_page.dart';
import 'esp_lua_page.dart';
import 'esp_skills_page.dart';
import 'esp_memory_page.dart';
import 'esp_mcp_page.dart';
import 'esp_scheduler_page.dart';
import 'esp_config_page.dart';

class EspDashboardPage extends StatefulWidget {
  const EspDashboardPage({Key? key}) : super(key: key);

  @override
  State<EspDashboardPage> createState() => _EspDashboardPageState();
}

class _EspDashboardPageState extends State<EspDashboardPage> {
  void _navigateTo(Widget page) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) => page));
  }

  void _restartDevice() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Restart Device?'),
        content: const Text('This will reboot the ESP-Claw device. Are you sure?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Restart'),
            onPressed: () {
              ConnectionManager.instance.api?.restart();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _disconnect() {
    ConnectionManager.instance.disconnect();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final device = ConnectionManager.instance.selectedDevice;
    final name = device?.name ?? 'Unknown Device';
    final ip = device?.ip ?? '0.0.0.0';
    final chip = device?.chip ?? 'ESP32';

    final actions = [
      _ActionItem('Chat', 'Web IM Interface', CupertinoIcons.chat_bubble_2_fill, const Color(0xFF0A84FF), const EspChatPage()),
      _ActionItem('Status', 'System Info', CupertinoIcons.device_laptop, const Color(0xFF30D158), const EspStatusPage()),
      _ActionItem('Features', 'Capabilities', CupertinoIcons.slider_horizontal_3, const Color(0xFFFF9F0A), const EspCapabilitiesPage()),
      _ActionItem('Files', 'Storage', CupertinoIcons.folder_fill, const Color(0xFF5E5CE6), const EspFilesPage()),
      _ActionItem('Lua Scripts', 'Code Modules', Icons.code_rounded, const Color(0xFFFF375F), const EspLuaPage()),
      _ActionItem('Skills', 'Agent Skills', CupertinoIcons.sparkles, const Color(0xFFBF5AF2), const EspSkillsPage()),
      _ActionItem('Memory', 'Long-term Storage', Icons.memory_rounded, const Color(0xFF64D2FF), const EspMemoryPage()),
      _ActionItem('MCP', 'Connections', CupertinoIcons.link, const Color(0xFFFFD60A), const EspMcpPage()),
      _ActionItem('Cron Jobs', 'Scheduler', CupertinoIcons.timer, const Color(0xFFFF9F0A), const EspSchedulerPage()),
      _ActionItem('Settings', 'Configuration', CupertinoIcons.settings, const Color(0xFF8E8E93), const EspConfigPage()),
    ];

    return CupertinoTheme(
      data: const CupertinoThemeData(brightness: Brightness.dark),
      child: Scaffold(
        backgroundColor: const Color(0xFF000000),
        appBar: AppBar(
          backgroundColor: const Color(0xAA000000),
          elevation: 0,
          flexibleSpace: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.transparent),
            ),
          ),
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back, color: Colors.white),
            onPressed: _disconnect,
          ),
          title: const Text(
            'ESP-Claw Dashboard',
            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600, fontFamily: '.SF Pro Text'),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            _buildHeader(name, ip, chip),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.15, // Wider aspect ratio prevents text overlap
                ),
                itemCount: actions.length,
                itemBuilder: (context, index) {
                  final item = actions[index];
                  return _buildActionCard(item, index);
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        color: const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(16),
                        onPressed: _disconnect,
                        child: const Text('Disconnect', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        color: const Color(0x33FF3B30),
                        borderRadius: BorderRadius.circular(16),
                        onPressed: _restartDevice,
                        child: const Text('Restart ESP', style: TextStyle(color: CupertinoColors.destructiveRed, fontSize: 16, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String ip, String chip) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141415),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x28FFFFFF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08007AFF),
            blurRadius: 20,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x2230D158),
                ),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: CupertinoColors.activeGreen,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: '.SF Pro Display'),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$chip • $ip',
                      style: const TextStyle(color: Color(0x88FFFFFF), fontSize: 14, fontFamily: '.SF Pro Text'),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05);
  }

  Widget _buildActionCard(_ActionItem item, int index) {
    return GestureDetector(
      onTap: () {
        if (item.page != null) {
          _navigateTo(item.page!);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141415),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0x11FFFFFF)),
          boxShadow: [
            BoxShadow(
              color: item.color.withOpacity(0.04),
              blurRadius: 15,
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: item.color, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600, fontFamily: '.SF Pro Text'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 11, fontFamily: '.SF Pro Text'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 350.ms, delay: (index * 40).ms).slideY(begin: 0.1, curve: Curves.easeOutCubic);
  }
}

class _ActionItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget? page;

  _ActionItem(this.title, this.subtitle, this.icon, this.color, this.page);
}
