import re

with open("cortexai_app/lib/espclaw/screens/device_discovery_page.dart", "r") as f:
    content = f.read()

# Fix initState to _loadRecentIp
if "_loadRecentIp" not in content:
    content = content.replace("  void initState() {\n    super.initState();\n    _startScanning();\n  }", "  void initState() {\n    super.initState();\n    _startScanning();\n    _loadRecentIp();\n  }\n\n  Future<void> _loadRecentIp() async {\n    final prefs = await SharedPreferences.getInstance();\n    final ip = prefs.getString('recent_esp_ip');\n    if (ip != null && ip.isNotEmpty && mounted) {\n      setState(() {\n        _ipController.text = ip;\n      });\n    }\n  }")

# Fix _connectToDevice to save IP
connect_device_old = """    if (success) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        CupertinoPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    }"""
connect_device_new = """    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('recent_esp_ip', device.ip);
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      }
    }"""
content = content.replace(connect_device_old, connect_device_new)

# Fix _connectManualIp to save IP
manual_ip_old = """  void _connectManualIp() {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) return;
    final device = EspClawDevice(name: 'ESP-Claw', ip: ip, status: 'online');
    _connectToDevice(device);
  }"""
manual_ip_new = """  void _connectManualIp() {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) return;
    final device = EspClawDevice(name: 'ESP-Claw', ip: ip, status: 'online');
    _connectToDevice(device);
  }"""

# PopScope and back button
if "PopScope" not in content:
    content = content.replace("child: Scaffold(", "child: PopScope(\n        canPop: false,\n        onPopInvokedWithResult: (didPop, result) async {\n          if (didPop) return;\n          ConnectionManager.instance.disconnect();\n          if (mounted) {\n            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(\n              CupertinoPageRoute(builder: (_) => const HomePage()),\n              (route) => false,\n            );\n          }\n        },\n        child: Scaffold(")
    content = content.replace("onPressed: () => Navigator.pop(context),", "onPressed: () {\n              ConnectionManager.instance.disconnect();\n              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(\n                CupertinoPageRoute(builder: (_) => const HomePage()),\n                (route) => false,\n              );\n            },")
    content = content.replace(").animate().fadeIn(duration: 300.ms, delay: (index * 60).ms).slideY(begin: 0.05, curve: Curves.easeOutCubic);\n  }\n}", ").animate().fadeIn(duration: 300.ms, delay: (index * 60).ms).slideY(begin: 0.05, curve: Curves.easeOutCubic);\n        ),\n  }\n}")

with open("cortexai_app/lib/espclaw/screens/device_discovery_page.dart", "w") as f:
    f.write(content)
