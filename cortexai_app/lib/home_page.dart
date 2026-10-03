import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'services/api_service.dart';
import 'template_action_page.dart';
import 'widgets/glass_template_card.dart';
import 'espclaw/screens/device_discovery_page.dart';
import 'espclaw/screens/esp_chat_page.dart';
import 'espclaw/screens/esp_config_page.dart';
import 'espclaw/screens/esp_status_page.dart';
import 'espclaw/screens/esp_capabilities_page.dart';
import 'espclaw/screens/esp_files_page.dart';
import 'espclaw/screens/esp_lua_page.dart';
import 'espclaw/screens/esp_skills_page.dart';
import 'espclaw/screens/esp_memory_page.dart';
import 'espclaw/screens/esp_mcp_page.dart';
import 'espclaw/screens/esp_scheduler_page.dart';
import 'espclaw/services/connection_manager.dart';

class _ActionItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget? page;

  _ActionItem(this.title, this.subtitle, this.icon, this.color, this.page);
}

/// Delicate white dot pattern painter for Vertex Agent card background
class WhiteDotPatternPainter extends CustomPainter {
  const WhiteDotPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0x1FFFFFFF) // Soft, refined white dots
      ..style = PaintingStyle.fill;

    const spacing = 18.0;
    const radius = 1.0;

    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _vertexAgentKey = GlobalKey();
  final GlobalKey _templatesKey = GlobalKey();

  List<Template> _templates = [];
  bool _isLoadingTemplates = true;
  bool _showAllTemplates = false;
  bool _isGridTemplateView =
      false; // defaults to horizontal deck matching reference image

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTemplates() async {
    try {
      final list = await ApiService.instance.fetchTemplates();
      if (mounted) {
        setState(() {
          _templates = list;
          _isLoadingTemplates = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingTemplates = false);
      }
    }
  }

  void _scrollToKey(GlobalKey key) {
    Navigator.of(context).maybePop(); // Close drawer if open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetContext = key.currentContext;
      if (targetContext != null) {
        Scrollable.ensureVisible(
          targetContext,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _openAgentConsole([String? prompt]) {
    Navigator.of(
      context,
    ).push(CupertinoPageRoute(builder: (context) => const EspChatPage()));
  }

  void _showInfoDialog(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoTheme(
        data: const CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.white,
        ),
        child: CupertinoAlertDialog(
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: Text(
            message,
            style: const TextStyle(color: Color(0xCCFFFFFF)),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountDialog() {
    Navigator.of(context).maybePop();
    final name = 'Abhishek Patel';
    final email = 'abhixyzxyz@gmail.com';

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoTheme(
        data: const CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.white,
        ),
        child: CupertinoActionSheet(
          title: Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          message: Text(
            '$email\n\nPlan: Cortex Developer Pro\nOrganization Admin',
            style: const TextStyle(color: Color(0xCCFFFFFF)),
          ),
          actions: [
            CupertinoActionSheetAction(
              child: const Text(
                'API Credentials',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoActionSheetAction(
              child: const Text(
                'Connected Devices',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _showConnectedDevicesSheet();
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            child: const Text('Close', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    Navigator.of(context).maybePop();
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoTheme(
        data: const CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.white,
        ),
        child: CupertinoActionSheet(
          title: const Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          message: Text(
            'API Gateway: ${ApiService.baseUrl}\nBackend: Go v1.20+ Gin\nDesign: Minimal Monochrome',
            style: const TextStyle(color: Color(0xCCFFFFFF)),
          ),
          actions: [
            CupertinoActionSheetAction(
              child: const Text(
                'Reload Templates',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() => _isLoadingTemplates = true);
                _loadTemplates();
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            child: const Text('Done', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  void _showConnectedDevicesSheet() async {
    Navigator.of(context).maybePop();
    List<EdgeDevice> devices = [];
    try {
      devices = await ApiService.instance.fetchDevices();
    } catch (_) {
      devices = const [
        EdgeDevice(
          id: 'node-esp32-s3-01',
          name: 'Living Room Edge Node',
          chip: 'ESP32-S3-WROOM-1',
          status: 'online',
          ipAddress: '192.168.1.101',
          firmwareVersion: 'v1.2.0-cortex',
          capabilities: ['audio-in', 'audio-out', 'gpio-control'],
          lastSeen: 'Now',
        ),
        EdgeDevice(
          id: 'node-esp32-p4-02',
          name: 'Vision Gateway P4',
          chip: 'ESP32-P4',
          status: 'online',
          ipAddress: '192.168.1.102',
          firmwareVersion: 'v1.4.1-cortex',
          capabilities: ['camera-stream', 'edge-inference'],
          lastSeen: 'Now',
        ),
      ];
    }

    if (!mounted) return;

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 380,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF0D0D0D),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0x33FFFFFF), width: 1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Connected Devices',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(
                    CupertinoIcons.xmark_circle_fill,
                    color: Colors.white60,
                    size: 22,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final dev = devices[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141416),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0x22FFFFFF)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dev.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${dev.chip} • ${dev.ipAddress}',
                              style: const TextStyle(
                                color: Color(0x88FFFFFF),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x1FFFFFFF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            dev.status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.white,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFF000000),
        body: SafeArea(child: _buildMainScrollContent()),
      ),
    );
  }

  Widget _buildMainScrollContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVertexAgentSection(),
                const SizedBox(height: 28),
                _buildTemplatesSection(),
                const SizedBox(height: 28),
                _buildEspClawSection(),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Refined Header of Home Page
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: Color(0xFF000000),
        border: Border(
          bottom: BorderSide(color: Color(0x1AFFFFFF), width: 0.8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Clean circular menu button
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF141416),
                border: Border.all(color: const Color(0x2EFFFFFF), width: 0.8),
              ),
              child: const Center(
                child: Icon(
                  CupertinoIcons.line_horizontal_3,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),

          // Center: Cortex logotype banner
          Hero(
            tag: 'cortex_head_logo',
            child: Image.asset(
              'lib/icon/head_banner.png',
              height: 34,
              fit: BoxFit.contain,
            ),
          ),

          // Right: Profile Avatar
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _showAccountDialog,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF141416),
                border: Border.all(color: const Color(0x38FFFFFF), width: 1.0),
              ),
              child: const Center(
                child: Text(
                  'AP',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Clean, professional Vertex Agent Card with subtle white dot pattern background
  Widget _buildVertexAgentSection() {
    return Container(
      key: _vertexAgentKey,
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C0E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x28FFFFFF), width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10007AFF), // subtle blue aura
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Light white dot pattern texture in background
            const Positioned.fill(
              child: CustomPaint(painter: WhiteDotPatternPainter()),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Removed redundant top badge
                  const SizedBox(height: 16),

                  const Text(
                    'Vertex Agent',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Direct orchestration interface for connected edge nodes, automated sensor routines, and system actions.',
                    style: TextStyle(
                      color: Color(0x99FFFFFF),
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Single, restrained White CTA Button
                  GestureDetector(
                    onTap: () => _openAgentConsole(),
                    child: Container(
                      height: 44,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Open Console',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.1,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            CupertinoIcons.arrow_right,
                            color: Colors.black,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEspClawSection() {
    final actions = [
      _ActionItem(
        'Status',
        'System Info',
        CupertinoIcons.device_laptop,
        const Color(0xFF30D158),
        const EspStatusPage(),
      ),
      _ActionItem(
        'Features',
        'Capabilities',
        CupertinoIcons.slider_horizontal_3,
        const Color(0xFFFF9F0A),
        const EspCapabilitiesPage(),
      ),
      _ActionItem(
        'Files',
        'Storage',
        CupertinoIcons.folder_fill,
        const Color(0xFF5E5CE6),
        const EspFilesPage(),
      ),
      _ActionItem(
        'Lua Scripts',
        'Code Modules',
        Icons.code_rounded,
        const Color(0xFFFF375F),
        const EspLuaPage(),
      ),
      _ActionItem(
        'Skills',
        'Agent Skills',
        CupertinoIcons.sparkles,
        const Color(0xFFBF5AF2),
        const EspSkillsPage(),
      ),
      _ActionItem(
        'MCP',
        'Connections',
        CupertinoIcons.link,
        const Color(0xFFFFD60A),
        const EspMcpPage(),
      ),
      _ActionItem(
        'Cron Jobs',
        'Scheduler',
        CupertinoIcons.timer,
        const Color(0xFFFF9F0A),
        const EspSchedulerPage(),
      ),
      _ActionItem(
        'Settings',
        'Configuration',
        CupertinoIcons.settings,
        const Color(0xFF8E8E93),
        const EspConfigPage(),
      ),
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
                      'Vertex Agent ESP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isConnected)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF34C759),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                if (!isConnected)
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text(
                      'Connect',
                      style: TextStyle(
                        color: CupertinoColors.activeBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).push(
                          CupertinoPageRoute(
                            builder: (_) => const DeviceDiscoveryPage(),
                          ),
                        ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isConnected
                  ? 'Connected to ${device?.name ?? "Device"} • ${device?.ip ?? ""}'
                  : 'Local Device Control & Hardware',
              style: TextStyle(
                color: isConnected
                    ? const Color(0xFF34C759)
                    : const Color(0x99FFFFFF),
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
      },
    );
  }

  Widget _buildActionCard(_ActionItem item, int index) {
    return GestureDetector(
          onTap: () {
            if (item.page != null) {
              Navigator.of(
                context,
              ).push(CupertinoPageRoute(builder: (_) => item.page!));
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0x99141415),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0x28FFFFFF)),
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withOpacity(0.04),
                      blurRadius: 15,
                    ),
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              fontFamily: '.SF Pro Text',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle,
                            style: const TextStyle(
                              color: Color(0x66FFFFFF),
                              fontSize: 11,
                              fontFamily: '.SF Pro Text',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 350.ms, delay: (index * 40).ms)
        .slideY(begin: 0.1, curve: Curves.easeOutCubic);
  }

  void _openTemplateAction(Template tpl, int index) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            TemplateActionPage(template: tpl, index: index),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  /// Templates Section featuring the reference 3D Frosted Glass Cards
  Widget _buildTemplatesSection() {
    return Column(
      key: _templatesKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title row with clean view toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Templates',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 8),
                if (!_isLoadingTemplates && _templates.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x18FFFFFF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_templates.length} READY',
                      style: const TextStyle(
                        color: Color(0xCCFFFFFF),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 4),

        const Text(
          'Instant edge routines • 1-tap deployment',
          style: TextStyle(
            color: Color(0x77FFFFFF),
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 16),

        if (_isLoadingTemplates)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CupertinoActivityIndicator(color: Colors.white),
            ),
          )
        else
          // Grid Mode: 2-Column Vertical Grid of Glass Cards
          Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _showAllTemplates
                    ? _templates.length
                    : (_templates.length > 6 ? 6 : _templates.length),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0, // Square cards
                ),
                itemBuilder: (context, index) {
                  final tpl = _templates[index];
                  return Hero(
                        tag: 'template_card_${tpl.id}',
                        child: Material(
                          type: MaterialType.transparency,
                          child: GlassTemplateCard(
                            template: tpl,
                            index: index,
                            onTap: () => _openTemplateAction(tpl, index),
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: (index * 35).ms)
                      .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic);
                },
              ),
              if (!_showAllTemplates && _templates.length > 6)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(12),
                    child: const Text(
                      'Load More',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () {
                      setState(() => _showAllTemplates = true);
                    },
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
