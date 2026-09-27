import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EspMemoryPage extends StatefulWidget {
  const EspMemoryPage({super.key});

  @override
  State<EspMemoryPage> createState() => _EspMemoryPageState();
}

class _EspMemoryPageState extends State<EspMemoryPage> {
  final List<Map<String, String>> _memories = [
    {'content': 'User prefers dark mode', 'timestamp': '2023-10-25 10:00'},
    {'content': 'Last known location: Office', 'timestamp': '2023-10-25 14:30'},
    {'content': 'Device IP is 192.168.1.104', 'timestamp': '2023-10-26 09:15'},
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF000000),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        middle: const Text('Memory', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600, fontFamily: '.SF Pro Text')),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CupertinoSearchTextField(
                backgroundColor: const Color(0xFF141416),
                itemColor: Colors.white,
                style: const TextStyle(color: Colors.white, fontFamily: '.SF Pro Text'),
                placeholder: 'Search memories...',
              ),
            ).animate().fadeIn().slideY(begin: 0.05),
            Expanded(
              child: _memories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(CupertinoIcons.tray, color: Color(0x99FFFFFF), size: 48),
                          const SizedBox(height: 16),
                          const Text('No memories stored', style: TextStyle(color: Color(0x99FFFFFF), fontFamily: '.SF Pro Text')),
                        ],
                      ).animate().fadeIn(),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _memories.length,
                      itemBuilder: (context, index) {
                        final memory = _memories[index];
                        return Dismissible(
                          key: Key(memory['timestamp']!),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: CupertinoColors.destructiveRed,
                            child: const Icon(CupertinoIcons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            setState(() => _memories.removeAt(index));
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0C0C0E),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0x28FFFFFF)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(memory['content']!, style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: '.SF Pro Text')),
                                    const SizedBox(height: 8),
                                    Text(memory['timestamp']!, style: const TextStyle(color: Color(0x99FFFFFF), fontSize: 12, fontFamily: '.SF Pro Text')),
                                  ],
                                ),
                              ),
                            ),
                          ).animate().fadeIn(duration: 300.ms, delay: (50 * index).ms).slideY(begin: 0.05),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
