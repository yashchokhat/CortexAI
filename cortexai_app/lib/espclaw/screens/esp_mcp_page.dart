import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EspMcpPage extends StatefulWidget {
  const EspMcpPage({super.key});

  @override
  State<EspMcpPage> createState() => _EspMcpPageState();
}

class _EspMcpPageState extends State<EspMcpPage> {
  final List<Map<String, dynamic>> _tools = [
    {
      'name': 'get_sensor_data',
      'description': 'Returns current temperature and humidity',
      'params': '[]',
    },
    {
      'name': 'toggle_led',
      'description': 'Turns built-in LED on or off',
      'params': '["state: boolean"]',
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
          'MCP Server',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            fontFamily: '.SF Pro Text',
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C0C0E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0x28FFFFFF)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Server Status',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: '.SF Pro Text',
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.circle_fill,
                            color: CupertinoColors.activeGreen,
                            size: 12,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Connected on Port 18791',
                            style: TextStyle(
                              color: Color(0x99FFFFFF),
                              fontSize: 15,
                              fontFamily: '.SF Pro Text',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn().slideY(begin: 0.05),
            const SizedBox(height: 24),
            const Text(
              'Available Tools',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: '.SF Pro Text',
              ),
            ),
            const SizedBox(height: 12),
            ..._tools
                .map(
                  (tool) => Container(
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
                        Text(
                          tool['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: '.SF Pro Text',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tool['description'],
                          style: const TextStyle(
                            color: Color(0x99FFFFFF),
                            fontSize: 13,
                            fontFamily: '.SF Pro Text',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Params: ${tool['params']}',
                          style: const TextStyle(
                            color: Color(0x55FFFFFF),
                            fontSize: 11,
                            fontFamily: 'Courier',
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton(
                            color: const Color(0x28FFFFFF),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: const Text(
                              'Call Tool',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            onPressed: () {
                              showCupertinoDialog(
                                context: context,
                                builder: (context) => CupertinoAlertDialog(
                                  title: Text('Call ${tool['name']}'),
                                  content: const Text(
                                    'Simulated successful execution.',
                                  ),
                                  actions: [
                                    CupertinoDialogAction(
                                      child: const Text('OK'),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
            const SizedBox(height: 24),
            CupertinoButton.filled(
              child: const Text('Discover MCP Devices'),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
