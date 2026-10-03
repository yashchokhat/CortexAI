import re

with open("cortexai_app/lib/espclaw/screens/device_discovery_page.dart", "r") as f:
    content = f.read()

# Make sure SharedPreferences is imported
if "import 'package:shared_preferences/shared_preferences.dart';" not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:shared_preferences/shared_preferences.dart';")
if "import '../../home_page.dart';" not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../../home_page.dart';")

# 1. Update initState to load IP
init_state_old = """  @override
  void initState() {
    super.initState();
    _startDiscovery();
  }"""
init_state_new = """  @override
  void initState() {
    super.initState();
    _startDiscovery();
    _loadRecentIp();
  }

  Future<void> _loadRecentIp() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString('recent_esp_ip');
    if (ip != null && ip.isNotEmpty && mounted) {
      setState(() {
        _ipController.text = ip;
      });
    }
  }"""
content = content.replace(init_state_old, init_state_new)

# 2. Update connect to save IP and push HomePage
connect_old = """    if (success) {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (_) => const EspDashboardPage()),
      );
    }"""
connect_new = """    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('recent_esp_ip', device.ip);
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      }
    }"""
content = content.replace(connect_old, connect_new)

# 3. Update build method to include PopScope and fix back button
build_old = """  @override
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
          ),"""

build_new = """  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: const CupertinoThemeData(brightness: Brightness.dark, primaryColor: Colors.white),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          ConnectionManager.instance.disconnect();
          if (mounted) {
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              CupertinoPageRoute(builder: (_) => const HomePage()),
              (route) => false,
            );
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF000000),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.back, color: Colors.white),
              onPressed: () {
                ConnectionManager.instance.disconnect();
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  CupertinoPageRoute(builder: (_) => const HomePage()),
                  (route) => false,
                );
              },
            ),"""

content = content.replace(build_old, build_new)

# 4. Add closing parenthesis for PopScope
# We know the end of the file is the end of the Scaffold then CupertinoTheme
end_old = """        ),
      ),
    );
  }

  Widget _buildDeviceCard(EspClawDevice device, int index) {"""
end_new = """        ),
      ),
      ),
    );
  }

  Widget _buildDeviceCard(EspClawDevice device, int index) {"""
content = content.replace(end_old, end_new)

with open("cortexai_app/lib/espclaw/screens/device_discovery_page.dart", "w") as f:
    f.write(content)
