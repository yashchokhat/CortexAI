import re

with open("cortexai_app/lib/home_page.dart", "r") as f:
    content = f.read()

# 1. Remove 'Vertex Agent' and 'Memory' from actions
content = re.sub(r"      _ActionItem\('Vertex Agent', 'Web IM Interface', CupertinoIcons.chat_bubble_2_fill, const Color\(0xFF0A84FF\), const EspChatPage\(\)\),\n", "", content)
content = re.sub(r"      _ActionItem\('Memory', 'Long-term Storage', Icons.memory_rounded, const Color\(0xFF64D2FF\), const EspMemoryPage\(\)\),\n", "", content)

# 2. Swap ESP-Claw and Templates sections in the column
old_order = """                        // Clean Vertex Agent Section with Light White Dots
                        _buildVertexAgentSection(),

                        const SizedBox(height: 28),
                        
                        // ESP-Claw Local Device Control Section
                        _buildEspClawSection(),

                        const SizedBox(height: 28),

                        // Vertical Templates Grid with API-backed Square Cards
                        _buildTemplatesSection(),

                        const SizedBox(height: 36),"""

new_order = """                        // Clean Vertex Agent Section with Light White Dots
                        _buildVertexAgentSection(),

                        const SizedBox(height: 28),

                        // Vertical Templates Grid with API-backed Square Cards
                        _buildTemplatesSection(),

                        const SizedBox(height: 28),
                        
                        // ESP-Claw Local Device Control Section
                        _buildEspClawSection(),

                        const SizedBox(height: 36),"""

content = content.replace(old_order, new_order)

# 3. Add BackdropFilter to _buildActionCard for glassmorphism
action_card_old = """      child: Container(
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
        child: Padding("""

action_card_new = """      child: ClipRRect(
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
                )
              ],
            ),
            child: Padding("""

content = content.replace(action_card_old, action_card_new)

# Add closing parenthesis for ClipRRect/BackdropFilter
content = re.sub(r"          \),\n        \),\n      \),\n    \)\.animate\(\)", "          ),\n        ),\n      ),\n      ),\n      ),\n    ).animate()", content)

with open("cortexai_app/lib/home_page.dart", "w") as f:
    f.write(content)

