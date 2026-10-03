import re

with open("cortexai_app/lib/espclaw/screens/device_discovery_page.dart", "r") as f:
    content = f.read()

# 1. Imports
if "import 'package:shared_preferences/shared_preferences.dart';" not in content:
    content = content.replace("import 'package:flutter/cupertino.dart';", "import 'package:flutter/cupertino.dart';\nimport 'package:shared_preferences/shared_preferences.dart';")
if "import '../../home_page.dart';" not in content:
    content = content.replace("import 'package:flutter/cupertino.dart';", "import 'package:flutter/cupertino.dart';\nimport '../../home_page.dart';")

# 2. _loadRecentIp
if "_loadRecentIp()" not in content:
    content = content.replace("  void initState() {\n    super.initState();\n    _startDiscovery();\n  }", "  void initState() {\n    super.initState();\n    _startDiscovery();\n    _loadRecentIp();\n  }\n\n  Future<void> _loadRecentIp() async {\n    final prefs = await SharedPreferences.getInstance();\n    final ip = prefs.getString('recent_esp_ip');\n    if (ip != null && ip.isNotEmpty && mounted) {\n      setState(() {\n        _ipController.text = ip;\n      });\n    }\n  }")

# 3. _connectToDevice
content = content.replace("Navigator.pushReplacement(\n        context,\n        CupertinoPageRoute(builder: (_) => const EspDashboardPage()),\n      );", "final prefs = await SharedPreferences.getInstance();\n      await prefs.setString('recent_esp_ip', device.ip);\n      if (!mounted) return;\n      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(\n        CupertinoPageRoute(builder: (_) => const HomePage()),\n        (route) => false,\n      );")
# 4. _connectManualIp
content = content.replace("final success = await ConnectionManager.instance.connect(device);\n    if (!mounted) return;\n\n    if (success) {\n      Navigator.pushReplacement(\n        context,\n        CupertinoPageRoute(builder: (_) => const EspDashboardPage()),\n      );\n    }", "final success = await ConnectionManager.instance.connect(device);\n    if (!mounted) return;\n\n    if (success) {\n      final prefs = await SharedPreferences.getInstance();\n      await prefs.setString('recent_esp_ip', ip);\n      if (!mounted) return;\n      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(\n        CupertinoPageRoute(builder: (_) => const HomePage()),\n        (route) => false,\n      );\n    }")

# 5. PopScope and back button
if "PopScope" not in content:
    content = content.replace("child: Scaffold(", "child: PopScope(\n        canPop: false,\n        onPopInvokedWithResult: (didPop, result) async {\n          if (didPop) return;\n          ConnectionManager.instance.disconnect();\n          if (mounted) {\n            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(\n              CupertinoPageRoute(builder: (_) => const HomePage()),\n              (route) => false,\n            );\n          }\n        },\n        child: Scaffold(")
    content = content.replace("onPressed: () => Navigator.pop(context),", "onPressed: () {\n              ConnectionManager.instance.disconnect();\n              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(\n                CupertinoPageRoute(builder: (_) => const HomePage()),\n                (route) => false,\n              );\n            },")
    # add parenthesis
    content = content.replace(").animate().fadeIn(duration: 300.ms, delay: (index * 60).ms).slideY(begin: 0.05, curve: Curves.easeOutCubic);\n  }\n}", ").animate().fadeIn(duration: 300.ms, delay: (index * 60).ms).slideY(begin: 0.05, curve: Curves.easeOutCubic);\n        ),\n  }\n}")

with open("cortexai_app/lib/espclaw/screens/device_discovery_page.dart", "w") as f:
    f.write(content)
