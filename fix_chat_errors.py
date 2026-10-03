import re

with open("cortexai_app/lib/espclaw/screens/esp_chat_page.dart", "r") as f:
    content = f.read()

# Make messages non-final
content = content.replace("final List<ChatMessage> messages = [];", "List<ChatMessage> messages = [];")

# Fix _loadMessages and _saveMessages
methods_old = """
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
"""

methods_new = """
  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('chat_history_${chat.ip}') ?? [];
    if (data.isNotEmpty) {
      setState(() {
        messages = data.map((e) {
          final map = jsonDecode(e);
          return ChatMessage(
            text: map['text'],
            sender: map['sender'] == 'user' ? MessageSender.user : MessageSender.assistant,
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
      'text': m.text,
      'sender': m.sender == MessageSender.user ? 'user' : 'assistant',
      'timestamp': m.timestamp.toIso8601String(),
    })).toList();
    await prefs.setStringList('chat_history_${chat.ip}', data);
  }
"""
content = content.replace(methods_old, methods_new)

# Fix _saveMessages calls that weren't replaced
# We need to find `messages.add(msg);` inside handleMessage and sendMessage and append _saveMessages();
# Instead of complex regex, let's just do:
def replace_add(match):
    return match.group(0) + "\n      _saveMessages();"

content = re.sub(r"messages\.add\(msg\);(\n\s+})", r"messages.add(msg);\n        _saveMessages();\1", content)
content = content.replace("    scrollToBottom();", "    _saveMessages();\n    scrollToBottom();")
# But wait, that might duplicate _saveMessages(); if I do both.
# Let's just restore original first.
