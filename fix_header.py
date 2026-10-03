import re

with open("cortexai_app/lib/home_page.dart", "r") as f:
    content = f.read()

# Remove AP avatar
avatar_regex = re.compile(r'                  Container\(\n                    width: 32,\n                    height: 32,\n                    decoration: BoxDecoration\(\n                      shape: BoxShape.circle,\n                      color: const Color\(0xFF141416\),\n                      border: Border.all\(\n                        color: const Color\(0x33FFFFFF\),\n                        width: 1.0,\n                      \),\n                    \),\n                    child: const Center\(\n                      child: Text\(\n                        \'AP\',\n                        style: TextStyle\(\n                          color: Colors.white,\n                          fontSize: 14,\n                          fontWeight: FontWeight.w700,\n                        \),\n                      \),\n                    \),\n                  \),\n                  const SizedBox\(width: 12\),')
content = avatar_regex.sub('', content)

# Move _buildHeader() inside _buildMainScrollContent()
# In build(BuildContext context):
#         body: SafeArea(
#           child: Column(
#             children: [
#               _buildHeader(),
#               Expanded(
#                 child: _buildMainScrollContent(),
#               ),
#             ],
#           ),
#         ),

build_regex = re.compile(r'        body: SafeArea\(\n          child: Column\(\n            children: \[\n              _buildHeader\(\),\n              Expanded\(\n                child: _buildMainScrollContent\(\),\n              \),\n            \],\n          \),\n        \),')
build_new = """        body: SafeArea(
          child: _buildMainScrollContent(),
        ),"""
content = build_regex.sub(build_new, content)

# And now inside _buildMainScrollContent:
#   Widget _buildMainScrollContent() {
#     return SingleChildScrollView(
#       controller: _scrollController,
#       physics: const BouncingScrollPhysics(),
#       child: Column(
#         crossAxisAlignment: CrossAxisAlignment.start,
#         children: [
#           _buildVertexAgentSection(),
main_scroll_regex = re.compile(r'  Widget _buildMainScrollContent\(\) \{\n    return SingleChildScrollView\(\n      controller: _scrollController,\n      physics: const BouncingScrollPhysics\(\),\n      padding: const EdgeInsets.symmetric\(horizontal: 16.0, vertical: 12.0\),\n      child: Column\(\n        crossAxisAlignment: CrossAxisAlignment.start,\n        children: \[')
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
              children: ["""
content = main_scroll_regex.sub(main_scroll_new, content)

main_scroll_end_regex = re.compile(r'            const SizedBox\(height: 36\),\n          \],\n        \),\n    \);\n  \}')
main_scroll_end_new = """            const SizedBox(height: 36),
            ],
          ),
        ],
      ),
    );
  }"""
content = main_scroll_end_regex.sub(main_scroll_end_new, content)

# Replace ESP-Claw with Vertex Agent ESP
content = content.replace("ESP-Claw", "Vertex Agent ESP")

with open("cortexai_app/lib/home_page.dart", "w") as f:
    f.write(content)
