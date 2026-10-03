import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EspSkillsPage extends StatefulWidget {
  const EspSkillsPage({super.key});

  @override
  State<EspSkillsPage> createState() => _EspSkillsPageState();
}

class _EspSkillsPageState extends State<EspSkillsPage> {
  final List<Map<String, dynamic>> _skills = [
    {
      'name': 'Weather Fetcher',
      'description': 'Fetches local weather',
      'category': 'Network',
      'enabled': true,
    },
    {
      'name': 'Motion Alerts',
      'description': 'PIR sensor triggers',
      'category': 'Environment',
      'enabled': false,
    },
    {
      'name': 'Smart Relay',
      'description': 'Controls connected relay',
      'category': 'GPIO',
      'enabled': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,

        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Skills',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            fontFamily: '.SF Pro Text',
          ),
        ),
        actions: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.cloud_upload, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _skills.length,
          itemBuilder: (context, index) {
            final skill = _skills[index];
            return ClipRRect(
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
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1C),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              CupertinoIcons.bolt_fill,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  skill['name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: '.SF Pro Text',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  skill['description'],
                                  style: const TextStyle(
                                    color: Color(0x99FFFFFF),
                                    fontSize: 13,
                                    fontFamily: '.SF Pro Text',
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0x28FFFFFF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    skill['category'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontFamily: '.SF Pro Text',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CupertinoSwitch(
                            value: skill['enabled'],
                            onChanged: (val) {
                              setState(() => skill['enabled'] = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 300.ms, delay: (50 * index).ms)
                .slideY(begin: 0.05);
          },
        ),
      ),
    );
  }
}
