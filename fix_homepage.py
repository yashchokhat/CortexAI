import re

with open("cortexai_app/lib/home_page.dart", "r") as f:
    content = f.read()

# 1. Imports
imports = """import 'espclaw/screens/esp_chat_page.dart';
import 'espclaw/screens/esp_config_page.dart';
import 'espclaw/screens/esp_status_page.dart';
import 'espclaw/screens/esp_capabilities_page.dart';
import 'espclaw/screens/esp_files_page.dart';
import 'espclaw/screens/esp_lua_page.dart';
import 'espclaw/screens/esp_skills_page.dart';
import 'espclaw/screens/esp_memory_page.dart';
import 'espclaw/screens/esp_mcp_page.dart';
import 'espclaw/screens/esp_scheduler_page.dart';
"""
content = re.sub(r"import 'espclaw/screens/esp_chat_page\.dart';\nimport 'espclaw/screens/esp_config_page\.dart';", imports, content)
content = content.replace("import 'auth_page.dart';\n", "")
content = content.replace("import 'services/auth_service.dart';\n", "")
content = content.replace("import 'vertex_ai_page.dart';\n", "")
content = content.replace("import 'espclaw/screens/esp_dashboard_page.dart';\n", "")

# 2. Add ActionItem class
action_item = """
class _ActionItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget? page;

  _ActionItem(this.title, this.subtitle, this.icon, this.color, this.page);
}

class HomePage extends StatefulWidget {
"""
content = content.replace("class HomePage extends StatefulWidget {", action_item)

# 3. Fix _openAgentConsole
agent_console_old = """  void _openAgentConsole([String? prompt]) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => VertexAIPage(initialPrompt: prompt),
      ),
    );
  }"""
agent_console_new = """  void _openAgentConsole([String? prompt]) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const EspChatPage(),
      ),
    );
  }"""
if "VertexAIPage" in content:
    content = content.replace(agent_console_old, agent_console_new)
else:
    content = re.sub(r"  void _openAgentConsole\(\[String\? prompt\]\) \{\n    Navigator\.of\(context\)\.push\(\n      CupertinoPageRoute\(\n        builder: \(context\) => VertexAiPage\(initialPrompt: prompt\),\n      \),\n    \);\n  \}", agent_console_new, content)

# 4. Remove Sign Out button from drawer
content = re.sub(r"              // Sign Out\n              Padding\([\s\S]*?            \],\n          \),\n        \),\n      \),\n    \);\n  \}", "            ],\n          ),\n        ),\n      ),\n    );\n  }", content)

# 5. Remove _handleSignOut
content = re.sub(r"  void _handleSignOut\(\) async \{[\s\S]*?  \}", "", content)

# 6. Replace _buildEspClawSection
esp_claw_new = """  Widget _buildEspClawSection() {
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
content = re.sub(r"  Widget _buildEspClawSection\(\) \{[\s\S]*?\}\n    \);\n  \}", esp_claw_new, content)


with open("cortexai_app/lib/home_page.dart", "w") as f:
    f.write(content)
