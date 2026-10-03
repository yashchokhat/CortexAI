import re

with open("cortexai_app/lib/espclaw/screens/esp_chat_page.dart", "r") as f:
    content = f.read()

# Add imports
imports = """import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
"""
content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\n" + imports)

# Add load/save methods
load_save = """
  @override
  void initState() {
    super.initState();
    _loadMessages();
"""
content = content.replace("  @override\n  void initState() {\n    super.initState();\n", load_save)

methods = """
  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('chat_history_${chat.ip}') ?? [];
    if (data.isNotEmpty) {
      setState(() {
        messages = data.map((e) {
          final map = jsonDecode(e);
          return ChatMessage(
            id: map['id'],
            text: map['text'],
            sender: map['sender'] == 'user' ? MessageSender.user : MessageSender.agent,
            timestamp: DateTime.parse(map['timestamp']),
          );
        }).toList();
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        if (scrollController.hasClients) {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final data = messages.map((m) => jsonEncode({
      'id': m.id,
      'text': m.text,
      'sender': m.sender == MessageSender.user ? 'user' : 'agent',
      'timestamp': m.timestamp.toIso8601String(),
    })).toList();
    await prefs.setStringList('chat_history_${chat.ip}', data);
  }
  
  void _clearChat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_history_${chat.ip}');
    setState(() {
      messages.clear();
    });
  }
"""

content = content.replace("  void _scrollToBottom() {", methods + "\n  void _scrollToBottom() {")

# Call _saveMessages when adding messages
content = content.replace("      messages.add(msg);\n    });\n    _scrollToBottom();", "      messages.add(msg);\n    });\n    _saveMessages();\n    _scrollToBottom();")

# Add "New Chat" button to AppBar
appbar_old = """          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Vertex Agent',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600, fontFamily: '.SF Pro Text'),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: connected ? CupertinoColors.activeGreen : CupertinoColors.destructiveRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    connected ? 'Connected' : 'Disconnected',
                    style: TextStyle(
                      color: connected ? const Color(0x99FFFFFF) : CupertinoColors.destructiveRed,
                      fontSize: 12,
                      fontFamily: '.SF Pro Text',
                    ),
                  ),
                ],
              ),
            ],
          ),
          centerTitle: true,
        ),"""

appbar_new = """          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Vertex Agent',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600, fontFamily: '.SF Pro Text'),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: connected ? CupertinoColors.activeGreen : CupertinoColors.destructiveRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    connected ? 'Connected' : 'Disconnected',
                    style: TextStyle(
                      color: connected ? const Color(0x99FFFFFF) : CupertinoColors.destructiveRed,
                      fontSize: 12,
                      fontFamily: '.SF Pro Text',
                    ),
                  ),
                ],
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _clearChat,
              child: const Icon(CupertinoIcons.trash, color: Colors.white, size: 20),
            ),
          ],
        ),"""

content = content.replace(appbar_old, appbar_new)

with open("cortexai_app/lib/espclaw/screens/esp_chat_page.dart", "w") as f:
    f.write(content)
print("Updated esp_chat_page")
