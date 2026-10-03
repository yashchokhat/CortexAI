import re

with open("cortexai_app/lib/home_page.dart", "r") as f:
    content = f.read()

# 1. Remove _navigatorKey and unused properties
content = re.sub(r'  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>\(\);\n', '', content)

# 2. _showAllTemplates state
if 'bool _showAllTemplates = false;' not in content:
    content = content.replace("bool _isLoadingTemplates = true;", "bool _isLoadingTemplates = true;\n  bool _showAllTemplates = false;")

# 3. Fix _openAgentConsole to use Navigator.of(context)
open_agent_old = """  void _openAgentConsole({String? prompt}) {
    _navigatorKey.currentState?.push(
      CupertinoPageRoute(builder: (_) => const EspChatPage()),
    );
  }"""
open_agent_new = """  void _openAgentConsole({String? prompt}) {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (_) => const EspChatPage()),
    );
  }"""
content = content.replace(open_agent_old, open_agent_new)

# 4. Rewrite _openTemplateAction
template_action_old = """  void _openTemplateAction(Template tpl, int index) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => TemplateActionPage(template: tpl, tagIndex: index),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }"""

template_action_new = """  void _openTemplateAction(Template tpl, int index) {
    if (ConnectionManager.instance.selectedDevice == null) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Not Connected', style: TextStyle(color: Colors.white)),
          content: const Text('Connect to an ESP-Claw device first.', style: TextStyle(color: Color(0xCCFFFFFF))),
          actions: [
            CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.pop(ctx)),
          ],
        ),
      );
      return;
    }

    final prompt = "KILL_ALL_TASKS\\nDO_TASK: ${tpl.actionPrompt}";
    ConnectionManager.instance.chatService.sendMessage(prompt);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Executed Template: ${tpl.title}'),
        backgroundColor: const Color(0xFF1C1C1E),
        duration: const Duration(seconds: 2),
      ),
    );
  }"""
content = content.replace(template_action_old, template_action_new)

# 5. Fix build method to remove Navigator and Drawer
build_method_regex = re.compile(r'  @override\n  Widget build\(BuildContext context\) \{.*?Widget _buildMainScrollContent\(\) \{', re.DOTALL)
build_method_new = """  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: const CupertinoThemeData(brightness: Brightness.dark, primaryColor: Colors.white),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFF000000),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildMainScrollContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainScrollContent() {"""
content = build_method_regex.sub(build_method_new, content)

# 6. Fix _buildMainScrollContent to return just the SingleChildScrollView since it's already in a Scaffold
main_scroll_regex = re.compile(r'  Widget _buildMainScrollContent\(\) \{\n    return Scaffold\(\n      backgroundColor: Colors\.black,\n      body: SingleChildScrollView\(', re.DOTALL)
main_scroll_new = """  Widget _buildMainScrollContent() {
    return SingleChildScrollView("""
content = main_scroll_regex.sub(main_scroll_new, content)

# Don't forget to remove the extra ); } for the old Scaffold in _buildMainScrollContent
# It ended with:
#             const SizedBox(height: 36),
#           ],
#         ),
#       ),
#     );
#   }
main_scroll_end_regex = re.compile(r'            const SizedBox\(height: 36\),\n          \],\n        \),\n      \),\n    \);\n  \}')
main_scroll_end_new = """            const SizedBox(height: 36),
          ],
        ),
    );
  }"""
content = main_scroll_end_regex.sub(main_scroll_end_new, content)

# 7. Modify _buildHeader to remove drawer icon
header_regex = re.compile(r'          Row\(\n            mainAxisAlignment: MainAxisAlignment\.spaceBetween,\n            children: \[\n              Row\(\n                children: \[\n                  CupertinoButton\(\n                    padding: EdgeInsets\.zero,\n                    onPressed: \(\) => _scaffoldKey\.currentState\?\.openDrawer\(\),\n                    child: const Icon\(CupertinoIcons\.bars, color: Colors\.white, size: 22\),\n                  \),\n                  const SizedBox\(width: 12\),', re.DOTALL)
header_new = """          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: ["""
content = header_regex.sub(header_new, content)

# 8. Fix EspClaw sections pushing to Navigator.of(context) instead of _navigatorKey
content = content.replace("_navigatorKey.currentState?.push", "Navigator.of(context).push")

# 9. Modify _buildTemplatesSection to show only 6 initially
grid_view_old = """          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _templates.length,"""
grid_view_new = """          Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _showAllTemplates ? _templates.length : (_templates.length > 6 ? 6 : _templates.length),"""
content = content.replace(grid_view_old, grid_view_new)

# Find the end of GridView.builder in _buildTemplatesSection
end_grid_regex = re.compile(r'                  \.slideY\(begin: 0\.06, end: 0, curve: Curves\.easeOutCubic\);\n            \},\n          \),')
end_grid_new = """                  .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic);
            },
          ),
          if (!_showAllTemplates && _templates.length > 6)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(12),
                child: const Text('Load More', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                onPressed: () {
                  setState(() => _showAllTemplates = true);
                },
              ),
            ),
          ],
        ),"""
content = end_grid_regex.sub(end_grid_new, content)

# 10. Delete _buildSideDrawer entirely
side_drawer_regex = re.compile(r'  /// Minimal Side Drawer in pure White & Black\n  Widget _buildSideDrawer\(\) \{.*', re.DOTALL)
content = side_drawer_regex.sub('', content)
content += "}\n" # close the class since we deleted until EOF

with open("cortexai_app/lib/home_page.dart", "w") as f:
    f.write(content)
