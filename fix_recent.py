with open("cortexai_app/lib/espclaw/screens/device_discovery_page.dart", "r") as f:
    content = f.read()

# Limit recent IPs to 3
content = content.replace("if (ips.length > 5) ips.removeLast();", "if (ips.length > 3) ips.removeLast();")

# Insert _buildRecentDevices() before manual IP entry
content = content.replace("              // Manual IP entry", "              _buildRecentDevices(),\n              // Manual IP entry")

with open("cortexai_app/lib/espclaw/screens/device_discovery_page.dart", "w") as f:
    f.write(content)
