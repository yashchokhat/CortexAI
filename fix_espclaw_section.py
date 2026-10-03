import re

with open("cortexai_app/lib/home_page.dart", "r") as f:
    content = f.read()

esp_claw_new = """  Widget _buildEspClawSection() {
    final actions = [
      _ActionItem('Vertex Agent', 'Web IM Interface', CupertinoIcons.chat_bubble_2_fill, const Color(0xFF0A84FF), const EspChatPage()),
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

    return StreamBuilder<bool>(
      stream: ConnectionManager.instance.isConnected,
      initialData: ConnectionManager.instance.selectedDevice != null,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? false;
        final device = ConnectionManager.instance.selectedDevice;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'ESP-Claw',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    if (isConnected)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: Color(0xFF34C759), shape: BoxShape.circle),
                      ),
                  ],
                ),
                if (!isConnected)
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Connect', style: TextStyle(color: CupertinoColors.activeBlue, fontSize: 13, fontWeight: FontWeight.w600)),
                    onPressed: () => Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const DeviceDiscoveryPage())),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isConnected ? 'Connected to ${device?.name ?? "Device"} • ${device?.ip ?? ""}' : 'Local Device Control & Hardware',
              style: TextStyle(
                color: isConnected ? const Color(0xFF34C759) : const Color(0x99FFFFFF),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
              ),
              itemCount: actions.length,
              itemBuilder: (context, index) {
                final item = actions[index];
                return _buildActionCard(item, index);
              },
            ),
          ],
        );
      }
    );
  }

  Widget _buildActionCard(_ActionItem item, int index) {
    return GestureDetector(
      onTap: () {
        if (item.page != null) {
          Navigator.of(context).push(CupertinoPageRoute(builder: (_) => item.page!));
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
"""

start_idx = content.find("  Widget _buildEspClawSection() {")
end_idx = content.find("  void _openTemplateAction(Template tpl, int index) {")

if start_idx != -1 and end_idx != -1:
    new_content = content[:start_idx] + esp_claw_new + "\n" + content[end_idx:]
    with open("cortexai_app/lib/home_page.dart", "w") as f:
        f.write(new_content)
    print("Patched successfully")
else:
    print("Could not find boundaries")
