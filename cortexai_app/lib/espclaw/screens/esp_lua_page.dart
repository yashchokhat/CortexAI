import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/connection_manager.dart';

class EspLuaPage extends StatefulWidget {
  const EspLuaPage({super.key});

  @override
  State<EspLuaPage> createState() => _EspLuaPageState();
}

class _EspLuaPageState extends State<EspLuaPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _modules = [];
  String _output = '';

  @override
  void initState() {
    super.initState();
    _fetchModules();
  }

  Future<void> _fetchModules() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      _modules = [
        {'name': 'sensor_monitor', 'description': 'Reads environment sensors', 'version': '1.0.2', 'enabled': true},
        {'name': 'led_control', 'description': 'Controls RGB strip', 'version': '0.9.1', 'enabled': false},
      ];
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _runScript() {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return CupertinoAlertDialog(
          title: const Text('Run Lua Script'),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: CupertinoTextField(
              controller: controller,
              maxLines: 5,
              placeholder: 'print("Hello World")',
              style: const TextStyle(color: Colors.white, fontFamily: 'Courier'),
              decoration: BoxDecoration(
                color: const Color(0xFF141416),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
            CupertinoDialogAction(
              child: const Text('Run'),
              onPressed: () {
                Navigator.pop(context);
                setState(() => _output += '\n> ${controller.text}\nExecuted successfully.');
              },
            ),
          ],
        );
      },
    );
  }

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
        middle: const Text('Lua Modules', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600, fontFamily: '.SF Pro Text')),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _runScript,
          child: const Icon(CupertinoIcons.play_circle_fill, color: Colors.white),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: _isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _modules.length,
                      itemBuilder: (context, index) {
                        final mod = _modules[index];
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
                                  const Icon(CupertinoIcons.cube_box, color: Colors.white, size: 28),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(mod['name'], style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: '.SF Pro Text')),
                                        const SizedBox(height: 4),
                                        Text(mod['description'], style: const TextStyle(color: Color(0x99FFFFFF), fontSize: 13, fontFamily: '.SF Pro Text')),
                                        const SizedBox(height: 4),
                                        Text('v${mod['version']}', style: const TextStyle(color: Color(0x99FFFFFF), fontSize: 11, fontFamily: '.SF Pro Text')),
                                      ],
                                    ),
                                  ),
                                  CupertinoSwitch(
                                    value: mod['enabled'],
                                    onChanged: (val) {
                                      setState(() => mod['enabled'] = val);
                                    },
                                    activeColor: CupertinoColors.activeBlue,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ).animate().fadeIn(duration: 300.ms, delay: (50 * index).ms).slideY(begin: 0.05);
                      },
                    ),
            ),
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0C0C0E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x28FFFFFF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Output Console', style: TextStyle(color: Color(0x99FFFFFF), fontSize: 13, fontFamily: '.SF Pro Text')),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _output.isEmpty ? 'Waiting for output...' : _output,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Courier'),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.05),
          ],
        ),
      ),
    );
  }
}
