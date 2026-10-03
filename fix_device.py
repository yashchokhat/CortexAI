import re

with open("cortexai_app/lib/espclaw/screens/device_discovery_page.dart", "r") as f:
    content = f.read()

# 1. Add SharedPreferences import if needed
if "import 'package:shared_preferences/shared_preferences.dart';" not in content:
    content = content.replace("import 'package:flutter/cupertino.dart';", "import 'package:flutter/cupertino.dart';\nimport 'package:shared_preferences/shared_preferences.dart';")

# 2. Add SharedPreferences logic to initState and _connectToManualIp
init_state = """  @override
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
content = content.replace(init_state, init_state_new)

# 3. Save IP on connect and navigate to HomePage
connect_device_old = """    if (success) {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (_) => const EspDashboardPage()),
      );
    }"""
connect_device_new = """    if (success) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        CupertinoPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    }"""
content = content.replace(connect_device_old, connect_device_new)

# Wait, the manual IP connect logic needs to save the IP
manual_ip_old = """    final success = await ConnectionManager.instance.connect(device);
    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (_) => const EspDashboardPage()),
      );
    }"""
manual_ip_new = """    final success = await ConnectionManager.instance.connect(device);
    if (!mounted) return;

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('recent_esp_ip', ip);
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        CupertinoPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    }"""
content = content.replace(manual_ip_old, manual_ip_new)

with open("cortexai_app/lib/espclaw/screens/device_discovery_page.dart", "w") as f:
    f.write(content)
