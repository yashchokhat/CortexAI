import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../services/connection_manager.dart';

class EspCapabilitiesPage extends StatefulWidget {
  const EspCapabilitiesPage({Key? key}) : super(key: key);

  @override
  State<EspCapabilitiesPage> createState() => _EspCapabilitiesPageState();
}

class _EspCapabilitiesPageState extends State<EspCapabilitiesPage> {
  bool _isLoading = true;
  List<dynamic> _capabilities = [];

  @override
  void initState() {
    super.initState();
    _fetchCapabilities();
  }

  Future<void> _fetchCapabilities() async {
    setState(() => _isLoading = true);
    final client = ConnectionManager.instance.api;
    if (client != null) {
      try {
        final data = await client.getCapabilities();
        if (mounted) {
          setState(() {
            _capabilities = data;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: const CupertinoThemeData(brightness: Brightness.dark),
      child: Scaffold(
        backgroundColor: const Color(0xFF000000),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Capabilities',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: _isLoading
            ? const Center(child: CupertinoActivityIndicator(radius: 16))
            : _capabilities.isEmpty
            ? const Center(
                child: Text(
                  'No capabilities found',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C0C0E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0x28FFFFFF)),
                      boxShadow: const [
                        BoxShadow(color: Color(0x10007AFF), blurRadius: 20),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _capabilities.length,
                          separatorBuilder: (context, index) => const Divider(
                            color: Color(0x28FFFFFF),
                            height: 1,
                            indent: 56,
                          ),
                          itemBuilder: (context, index) {
                            final cap = _capabilities[index];
                            final name = cap['name'] ?? cap.toString();
                            final enabled = cap['enabled'] ?? true;

                            return ListTile(
                                  leading: const Icon(
                                    CupertinoIcons.checkmark_circle_fill,
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  trailing: enabled
                                      ? const Icon(
                                          CupertinoIcons.check_mark,
                                          color: CupertinoColors.activeGreen,
                                        )
                                      : const Icon(
                                          CupertinoIcons.clear,
                                          color: CupertinoColors.destructiveRed,
                                        ),
                                )
                                .animate()
                                .fadeIn(
                                  duration: 300.ms,
                                  delay: (index * 50).ms,
                                )
                                .slideX(begin: 0.05);
                          },
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),
                ],
              ),
      ),
    );
  }
}
