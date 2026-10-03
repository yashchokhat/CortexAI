import re

with open("cortexai_app/lib/home_page.dart", "r") as f:
    content = f.read()

# Let's fix the build and _buildMainScrollContent completely.
# In build:
build_regex = re.compile(r'  @override\n  Widget build\(BuildContext context\) \{.*?Widget _buildMainScrollContent\(\) \{', re.DOTALL)
build_new = """  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: const CupertinoThemeData(brightness: Brightness.dark, primaryColor: Colors.white),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFF000000),
        body: SafeArea(
          child: _buildMainScrollContent(),
        ),
      ),
    );
  }

  Widget _buildMainScrollContent() {"""
content = build_regex.sub(build_new, content)

# In _buildMainScrollContent:
main_scroll_regex = re.compile(r'  Widget _buildMainScrollContent\(\) \{.*?\}\n\n  /// Refined Header of Home Page', re.DOTALL)
main_scroll_new = """  Widget _buildMainScrollContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Padding(
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
        ],
      ),
    );
  }

  /// Refined Header of Home Page"""
content = main_scroll_regex.sub(main_scroll_new, content)

with open("cortexai_app/lib/home_page.dart", "w") as f:
    f.write(content)
