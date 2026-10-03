import 'dart:io';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/chat_message.dart';
import '../websocket/esp_claw_chat.dart';
import '../websocket/chat_protocol_adapter.dart';
import '../services/connection_manager.dart';

class EspChatPage extends StatefulWidget {
  const EspChatPage({Key? key}) : super(key: key);

  @override
  State<EspChatPage> createState() => _EspChatPageState();
}

class _EspChatPageState extends State<EspChatPage> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();
  List<ChatMessage> messages = [];

  late EspClawChat chat;
  bool connected = false;
  bool sending = false;
  String? _currentMessageId;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    final deviceIp =
        ConnectionManager.instance.selectedDevice?.ip ?? '192.168.1.6';
    chat = EspClawChat(ip: deviceIp);
    connect();
  }

  void connect() {
    chat.connect(
      onMessage: handleMessage,
      onError: (error) {
        if (mounted) {
          setState(() {
            connected = false;
          });
        }
      },
      onDisconnected: () {
        if (mounted) {
          setState(() {
            connected = false;
          });
        }
      },
    );
    setState(() {
      connected = true;
    });
  }

  void handleMessage(dynamic data) {
    if (data is String) {
      try {
        final Map<String, dynamic> json = jsonDecode(data);
        final String text = json['text']?.toString() ?? '';
        final String? msgId = json['message_id']?.toString();
        final bool isFinal = json['final'] == true;

        if (text.isEmpty && !isFinal) return;

        if (mounted) {
          setState(() {
            sending = false;
            if (_currentMessageId != null &&
                _currentMessageId == msgId &&
                messages.isNotEmpty &&
                messages.last.sender == MessageSender.assistant) {
              // Append to existing stream
              final last = messages.removeLast();
              messages.add(
                ChatMessage(
                  text: last.text + text,
                  sender: MessageSender.assistant,
                ),
              );
            } else {
              // New message
              messages.add(
                ChatMessage(text: text, sender: MessageSender.assistant),
              );
              _currentMessageId = msgId;
            }
            if (isFinal) {
              _currentMessageId = null;
            }
          });
          _saveMessages();
          scrollToBottom();
        }
      } catch (_) {
        // Fallback for non-JSON or other formats
        final text = ChatProtocolAdapter.extractText(data);
        if (text.isEmpty) return;
        if (mounted) {
          setState(() {
            sending = false;
            messages.add(
              ChatMessage(text: text, sender: MessageSender.assistant),
            );
          });
          _saveMessages();
          scrollToBottom();
        }
      }
    }
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('chat_history_${chat.ip}') ?? [];
    if (data.isNotEmpty) {
      setState(() {
        messages = data.map((e) {
          final map = jsonDecode(e);
          return ChatMessage(
            text: map['text'],
            sender: map['sender'] == 'user'
                ? MessageSender.user
                : MessageSender.assistant,
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
    final data = messages
        .map(
          (m) => jsonEncode({
            'text': m.text,
            'sender': m.sender == MessageSender.user ? 'user' : 'assistant',
            'timestamp': m.timestamp.toIso8601String(),
          }),
        )
        .toList();
    await prefs.setStringList('chat_history_${chat.ip}', data);
  }

  void _clearChat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_history_${chat.ip}');
    setState(() {
      messages.clear();
    });
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void sendMessage() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add(ChatMessage(text: text, sender: MessageSender.user));
      sending = true;
    });

    controller.clear();
    _saveMessages();
    scrollToBottom();

    final client = ConnectionManager.instance.api;
    if (client != null) {
      try {
        await client.postData('/api/webim/send', {
          'chat_id': 'default',
          'text': text,
        });

        // Safety timeout in case the LLM backend (like Ollama) takes too long or fails
        Future.delayed(const Duration(seconds: 45), () {
          if (mounted && sending) {
            setState(() => sending = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Agent is taking a long time to respond. Ensure your LLM backend is accessible to the ESP32 (e.g. OLLAMA_HOST=0.0.0.0).',
                ),
              ),
            );
          }
        });
      } catch (e) {
        if (mounted) {
          setState(() => sending = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
        }
      }
    } else {
      // Fallback if not using api client
      try {
        final uri = Uri.parse('http://${chat.ip}/api/webim/send');
        final httpClient = HttpClient();
        final request = await httpClient.postUrl(uri);
        final jsonString = jsonEncode({'chat_id': 'default', 'text': text});
        final bytes = utf8.encode(jsonString);
        request.headers.contentType = ContentType.json;
        request.headers.contentLength = bytes.length;
        request.add(bytes);

        final response = await request.close().timeout(
          const Duration(seconds: 10),
        );
        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode}');
        }

        Future.delayed(const Duration(seconds: 45), () {
          if (mounted && sending) {
            setState(() => sending = false);
          }
        });
      } catch (e) {
        if (mounted) {
          setState(() => sending = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send fallback message: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    chat.close();
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.sender == MessageSender.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child:
          Container(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                decoration: BoxDecoration(
                  color: isUser
                      ? CupertinoColors.activeBlue
                      : const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isUser ? 20 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  msg.text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                    fontFamily: '.SF Pro Text',
                    fontWeight: isUser ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              )
              .animate()
              .scale(delay: 50.ms, duration: 200.ms, curve: Curves.easeOutBack)
              .fadeIn(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: const CupertinoThemeData(brightness: Brightness.dark),
      child: Scaffold(
        backgroundColor: const Color(0xFF000000),
        appBar: AppBar(
          backgroundColor: const Color(0xAA000000),
          elevation: 0,
          flexibleSpace: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(color: Colors.transparent),
            ),
          ),
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Vertex Agent',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  fontFamily: '.SF Pro Text',
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: connected
                          ? CupertinoColors.activeGreen
                          : CupertinoColors.destructiveRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    connected ? 'Connected' : 'Disconnected',
                    style: TextStyle(
                      color: connected
                          ? const Color(0x99FFFFFF)
                          : CupertinoColors.destructiveRed,
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
              child: const Icon(
                CupertinoIcons.trash,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(messages[index]);
                  },
                ),
              ),
              if (sending)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(left: 16, bottom: 8),
                    child: const CupertinoActivityIndicator(radius: 10),
                  ),
                ).animate().fadeIn(),

              // Input Area
              Container(
                margin: const EdgeInsets.only(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  top: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF141415),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0x33FFFFFF)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: '.SF Pro Text',
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Message Vertex Agent...',
                          hintStyle: TextStyle(color: Color(0x66FFFFFF)),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        onSubmitted: (_) => sendMessage(),
                      ),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.all(8),
                      onPressed: sendMessage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: connected
                              ? CupertinoColors.activeBlue
                              : const Color(0x33FFFFFF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.arrow_up,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
