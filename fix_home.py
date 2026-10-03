import re

with open("cortexai_app/lib/home_page.dart", "r") as f:
    content = f.read()

content = content.replace("Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const DeviceDiscoveryPage())),", "Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(builder: (_) => const DeviceDiscoveryPage())),")

with open("cortexai_app/lib/home_page.dart", "w") as f:
    f.write(content)
