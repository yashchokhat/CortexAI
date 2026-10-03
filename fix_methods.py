import re

with open("cortexai_app/lib/espclaw/screens/esp_chat_page.dart", "r") as f:
    content = f.read()

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

content = content.replace("  void scrollToBottom() {", methods + "\n  void scrollToBottom() {")
content = content.replace("    _saveMessages();\n    _scrollToBottom();", "    _saveMessages();\n    scrollToBottom();")

with open("cortexai_app/lib/espclaw/screens/esp_chat_page.dart", "w") as f:
    f.write(content)
print("done")
