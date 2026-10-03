import re

with open("cortexai_app/lib/espclaw/screens/device_discovery_page.dart", "r") as f:
    content = f.read()

# Replace _loadRecentIp
load_ip_old = """  Future<void> _loadRecentIp() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString('recent_esp_ip');
    if (ip != null && ip.isNotEmpty && mounted) {
      setState(() {
        _ipController.text = ip;
      });
    }
  }"""
load_ip_new = """  List<String> _recentIps = [];

  Future<void> _loadRecentIp() async {
    final prefs = await SharedPreferences.getInstance();
    final ips = prefs.getStringList('recent_esp_ips') ?? [];
    if (ips.isNotEmpty && mounted) {
      setState(() {
        _recentIps = ips;
        _ipController.text = ips.first;
      });
    }
  }

  Future<void> _saveRecentIp(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    final ips = prefs.getStringList('recent_esp_ips') ?? [];
    ips.remove(ip);
    ips.insert(0, ip);
    if (ips.length > 5) ips.removeLast();
    await prefs.setStringList('recent_esp_ips', ips);
  }"""
content = content.replace(load_ip_old, load_ip_new)

# Replace await prefs.setString('recent_esp_ip', device.ip);
content = content.replace("final prefs = await SharedPreferences.getInstance();\n      await prefs.setString('recent_esp_ip', device.ip);", "await _saveRecentIp(device.ip);")
# Also the manual one:
content = content.replace("final prefs = await SharedPreferences.getInstance();\n      await prefs.setString('recent_esp_ip', ip);", "await _saveRecentIp(ip);")

# Enhance the UI: add _buildRecentDevices()
build_recent_new = """  Widget _buildRecentDevices() {
    if (_recentIps.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text('RECENT CONNECTIONS', style: TextStyle(color: Color(0x99FFFFFF), fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
        ),
        ..._recentIps.map((ip) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _connectToDevice(EspClawDevice(name: 'Vertex Agent ESP', ip: ip, status: 'offline')),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0C0C0E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x28FFFFFF)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1C1C1E),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(CupertinoIcons.clock, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Vertex Agent ESP', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(ip, style: const TextStyle(color: Color(0x99FFFFFF), fontSize: 14)),
                      ],
                    ),
                  ),
                  const Icon(CupertinoIcons.chevron_right, color: Color(0x66FFFFFF), size: 16),
                ],
              ),
            ),
          ),
        )).toList(),
        const SizedBox(height: 24),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }"""

# Insert _buildRecentDevices before build
content = content.replace("  @override\n  Widget build(BuildContext context) {", build_recent_new + "\n\n  @override\n  Widget build(BuildContext context) {")

# Add _buildRecentDevices() inside the build method, right before _buildManualEntry
content = content.replace("_buildManualEntry(),\n                  const SizedBox(height: 40),", "_buildRecentDevices(),\n                  _buildManualEntry(),\n                  const SizedBox(height: 40),")

with open("cortexai_app/lib/espclaw/screens/device_discovery_page.dart", "w") as f:
    f.write(content)
