import re

with open("cortexai_app/lib/espclaw/screens/device_discovery_page.dart", "r") as f:
    content = f.read()

# 1. Add PopScope around Scaffold
old_build = """  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(style: const TextStyle(decoration: TextDecoration.none, color: Colors.white, fontFamily: '.SF Pro Text'), child: CupertinoTheme(
      data: const CupertinoThemeData(brightness: Brightness.dark),
      child: Scaffold(
        backgroundColor: const Color(0xFF000000),"""

new_build = """  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(style: const TextStyle(decoration: TextDecoration.none, color: Colors.white, fontFamily: '.SF Pro Text'), child: CupertinoTheme(
      data: const CupertinoThemeData(brightness: Brightness.dark),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          ConnectionManager.instance.disconnect();
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              CupertinoPageRoute(builder: (_) => const HomePage()),
              (route) => false,
            );
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF000000),"""

content = content.replace(old_build, new_build)

# 2. Add closing parenthesis for PopScope
# We need to find the end of the build method
content = content.replace(";\n  }\n}", ";\n        ),\n  }\n}")
# Actually better to use regex to find the end
# Since `Scaffold` is inside `PopScope`, we need an extra `)` for PopScope
content = re.sub(r"(\s+)\);\n  }\n}", r"\1  ),\n\1);\n  }\n}", content)

# 3. Add back button to AppBar
appbar_old = """        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Connect ESP-Claw', style: TextStyle(color: Colors.white)),
          actions: ["""

appbar_new = """        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back, color: Colors.white),
            onPressed: () {
              ConnectionManager.instance.disconnect();
              Navigator.of(context).pushAndRemoveUntil(
                CupertinoPageRoute(builder: (_) => const HomePage()),
                (route) => false,
              );
            },
          ),
          title: const Text('Connect ESP-Claw', style: TextStyle(color: Colors.white)),
          actions: ["""

content = content.replace(appbar_old, appbar_new)

# Add import for HomePage
if "import '../../home_page.dart';" not in content:
    content = content.replace("import 'package:flutter/cupertino.dart';", "import 'package:flutter/cupertino.dart';\nimport '../../home_page.dart';")

with open("cortexai_app/lib/espclaw/screens/device_discovery_page.dart", "w") as f:
    f.write(content)
