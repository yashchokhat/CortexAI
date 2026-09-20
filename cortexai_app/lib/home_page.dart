import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'auth_page.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'vertex_ai_page.dart';

/// Delicate white dot pattern painter for Vertex Agent card background
class WhiteDotPatternPainter extends CustomPainter {
  const WhiteDotPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x1FFFFFFF) // Soft, refined white dots
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
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => VertexAIPage(initialPrompt: prompt),
      ),
    );
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
          content: Text(message, style: const TextStyle(color: Color(0xCCFFFFFF))),
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
    final user = AuthService.instance.currentUser;
    final name = user?.displayName ?? 'Abhishek Patel';
    final email = user?.email ?? 'abhixyzxyz@gmail.com';

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoTheme(
        data: const CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.white,
        ),
        child: CupertinoActionSheet(
          title: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          message: Text('$email\n\nPlan: Cortex Developer Pro\nOrganization Admin', style: const TextStyle(color: Color(0xCCFFFFFF))),
          actions: [
            CupertinoActionSheetAction(
              child: const Text('API Credentials', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoActionSheetAction(
              child: const Text('Connected Devices', style: TextStyle(color: Colors.white)),
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
          title: const Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          message: Text('API Gateway: ${ApiService.baseUrl}\nBackend: Go v1.20+ Gin\nDesign: Minimal Monochrome', style: const TextStyle(color: Color(0xCCFFFFFF))),
          actions: [
            CupertinoActionSheetAction(
              child: const Text('Reload Templates', style: TextStyle(color: Colors.white)),
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
                  child: const Icon(CupertinoIcons.xmark_circle_fill, color: Colors.white60, size: 22),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

  void _handleSignOut() async {
    await AuthService.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) => const AuthPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Color(0xFF000000),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          decoration: TextDecoration.none,
          color: Colors.white,
          fontFamily: '.SF Pro Text',
        ),
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFF000000),
          drawer: _buildSideDrawer(),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Clean Vertex Agent Section with Light White Dots
                        _buildVertexAgentSection(),

                        const SizedBox(height: 28),

                        // Vertical Templates Grid with API-backed Square Cards
                        _buildTemplatesSection(),

                        const SizedBox(height: 36),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
          bottom: BorderSide(
            color: Color(0x1AFFFFFF),
            width: 0.8,
          ),
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
                border: Border.all(
                  color: const Color(0x2EFFFFFF),
                  width: 0.8,
                ),
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
                border: Border.all(
                  color: const Color(0x38FFFFFF),
                  width: 1.0,
                ),
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
        border: Border.all(
          color: const Color(0x28FFFFFF),
          width: 0.8,
        ),
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
              child: CustomPaint(
                painter: WhiteDotPatternPainter(),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0x18FFFFFF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0x2AFFFFFF)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.circle_fill, size: 6, color: Color(0xFF34C759)),
                            SizedBox(width: 6),
                            Text(
                              'VERTEX AGENT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'Ready',
                        style: TextStyle(
                          color: Color(0x88FFFFFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

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
                          Icon(CupertinoIcons.arrow_right, color: Colors.black, size: 14),
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

  /// Vertical Templates Section with 2-Column Square Cards
  Widget _buildTemplatesSection() {
    return Column(
      key: _templatesKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            if (!_isLoadingTemplates && _templates.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0x18FFFFFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_templates.length} ACTIVE',
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

        const SizedBox(height: 4),

        const Text(
          'Instant edge routines fetched live from cluster.',
          style: TextStyle(
            color: Color(0x77FFFFFF),
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 14),

        if (_isLoadingTemplates)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CupertinoActivityIndicator(color: Colors.white),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _templates.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0, // Clean square cards
            ),
            itemBuilder: (context, index) {
              final tpl = _templates[index];
              return _buildSquareTemplateCard(tpl, index);
            },
          ),
      ],
    );
  }

  /// Square Card Widget for Template
  Widget _buildSquareTemplateCard(Template tpl, int index) {
    final iconData = _getIconForTemplate(tpl.icon);

    return GestureDetector(
      onTap: () => _openAgentConsole(tpl.actionPrompt),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0x22FFFFFF),
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top row: Icon in subtle frosted pill + category chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0x18007AFF), // subtle blue tint
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0x33007AFF),
                      width: 0.8,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      iconData,
                      size: 17,
                      color: const Color(0xFF80D8FF),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0x14FFFFFF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tpl.chip,
                    style: const TextStyle(
                      color: Color(0xAAFFFFFF),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            // Middle: Title & brief description
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tpl.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tpl.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0x77FFFFFF),
                    fontSize: 10.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),

            // Bottom action link
            const Row(
              children: [
                Text(
                  'Run routine',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(CupertinoIcons.chevron_right, size: 10, color: Colors.white70),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: (index * 40).ms)
        .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic);
  }

  IconData _getIconForTemplate(String icon) {
    switch (icon) {
      case 'weather':
        return CupertinoIcons.cloud_sun_fill;
      case 'score':
        return CupertinoIcons.sportscourt_fill;
      case 'lightbulb_on':
        return CupertinoIcons.lightbulb_fill;
      case 'thermo':
        return CupertinoIcons.thermometer;
      case 'lightbulb_off':
        return CupertinoIcons.lightbulb;
      case 'bell':
        return CupertinoIcons.bell_fill;
      case 'gauge':
        return CupertinoIcons.gauge;
      case 'alert':
        return CupertinoIcons.exclamationmark_shield_fill;
      default:
        return CupertinoIcons.circle_grid_hex_fill;
    }
  }

  /// Minimal Side Drawer in pure White & Black
  Widget _buildSideDrawer() {
    final user = AuthService.instance.currentUser;
    final name = user?.displayName ?? 'Abhishek Patel';
    final email = user?.email ?? 'abhixyzxyz@gmail.com';

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        color: const Color(0xFF0A0A0C),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drawer Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'lib/icon/head_banner.png',
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF141416),
                            border: Border.all(
                              color: const Color(0x33FFFFFF),
                              width: 1.0,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'AP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0x77FFFFFF),
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(color: Color(0x1AFFFFFF), height: 1),

              // Drawer Navigation Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  children: [
                    _buildDrawerSectionTitle('NAVIGATION'),
                    _buildDrawerItem(
                      icon: CupertinoIcons.home,
                      title: 'Dashboard Overview',
                      onTap: () {
                        Navigator.of(context).maybePop();
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOut,
                        );
                      },
                    ),
                    _buildDrawerItem(
                      icon: CupertinoIcons.circle_grid_hex_fill,
                      title: 'Vertex Agent',
                      badge: 'CONSOLE',
                      onTap: () {
                        Navigator.of(context).maybePop();
                        _openAgentConsole();
                      },
                    ),
                    _buildDrawerItem(
                      icon: CupertinoIcons.square_grid_2x2_fill,
                      title: 'Templates',
                      badge: '${_templates.length}',
                      onTap: () => _scrollToKey(_templatesKey),
                    ),

                    const SizedBox(height: 16),
                    _buildDrawerSectionTitle('PREFERENCES'),
                    _buildDrawerItem(
                      icon: CupertinoIcons.person_crop_circle,
                      title: 'Account Profile',
                      onTap: _showAccountDialog,
                    ),
                    _buildDrawerItem(
                      icon: CupertinoIcons.gear_alt_fill,
                      title: 'System Settings',
                      onTap: _showSettingsDialog,
                    ),
                    _buildDrawerItem(
                      icon: CupertinoIcons.antenna_radiowaves_left_right,
                      title: 'Connected Devices',
                      badge: 'GO API',
                      onTap: _showConnectedDevicesSheet,
                    ),
                    _buildDrawerItem(
                      icon: CupertinoIcons.book_fill,
                      title: 'Documentation',
                      onTap: () {
                        Navigator.of(context).maybePop();
                        _showInfoDialog('Documentation', 'CortexAI Edge Developer Manual: https://cortexai.dev');
                      },
                    ),
                  ],
                ),
              ),

              const Divider(color: Color(0x1AFFFFFF), height: 1),

              // Sign Out
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: const Color(0x14FFFFFF),
                  borderRadius: BorderRadius.circular(14),
                  onPressed: _handleSignOut,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.square_arrow_left, size: 16, color: Colors.white70),
                      SizedBox(width: 8),
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 10, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0x66FFFFFF),
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    String? badge,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
        onPressed: onTap,
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0x1FFFFFFF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
