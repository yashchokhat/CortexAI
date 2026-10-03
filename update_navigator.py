import re

with open("cortexai_app/lib/home_page.dart", "r") as f:
    content = f.read()

# Add _navigatorKey to _HomePageState
content = content.replace("class _HomePageState extends State<HomePage> {", 
                          "class _HomePageState extends State<HomePage> {\n  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();")

# Replace build method to use nested Navigator
old_build = """  @override
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

                        const SizedBox(height: 28),
                        
                        // ESP-Claw Local Device Control Section
                        _buildEspClawSection(),

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
  }"""

new_build = """  @override
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
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            if (_navigatorKey.currentState != null && _navigatorKey.currentState!.canPop()) {
              _navigatorKey.currentState!.pop();
            } else {
              // exit app? or do nothing
            }
          },
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: const Color(0xFF000000),
            drawer: _buildSideDrawer(),
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Navigator(
                      key: _navigatorKey,
                      onGenerateRoute: (settings) {
                        return CupertinoPageRoute(
                          builder: (context) => _buildMainScrollContent(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainScrollContent() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
    );
  }"""

content = content.replace(old_build, new_build)

# Ensure navigator is used in drawer instead of context
drawer_nav_old = """Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const EspChatPage()));"""
drawer_nav_new = """_navigatorKey.currentState?.push(CupertinoPageRoute(builder: (_) => const EspChatPage()));"""
content = content.replace(drawer_nav_old, drawer_nav_new)

drawer_nav_old_2 = """Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const EspConfigPage()));"""
drawer_nav_new_2 = """_navigatorKey.currentState?.push(CupertinoPageRoute(builder: (_) => const EspConfigPage()));"""
content = content.replace(drawer_nav_old_2, drawer_nav_new_2)

# Ensure grid view uses nested navigator
grid_nav_old = """Navigator.of(context).push(CupertinoPageRoute(builder: (_) => item.page!));"""
grid_nav_new = """_navigatorKey.currentState?.push(CupertinoPageRoute(builder: (_) => item.page!));"""
content = content.replace(grid_nav_old, grid_nav_new)

# Agent console uses nested navigator
agent_nav_old = """Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const EspChatPage(),
      ),
    );"""
agent_nav_new = """_navigatorKey.currentState?.push(
      CupertinoPageRoute(
        builder: (context) => const EspChatPage(),
      ),
    );"""
content = content.replace(agent_nav_old, agent_nav_new)

with open("cortexai_app/lib/home_page.dart", "w") as f:
    f.write(content)
print("done")
