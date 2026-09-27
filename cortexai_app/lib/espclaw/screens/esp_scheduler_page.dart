import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EspSchedulerPage extends StatefulWidget {
  const EspSchedulerPage({super.key});

  @override
  State<EspSchedulerPage> createState() => _EspSchedulerPageState();
}

class _EspSchedulerPageState extends State<EspSchedulerPage> {
  final List<Map<String, dynamic>> _tasks = [
    {'name': 'Nightly Backup', 'schedule': 'Every day at 02:00', 'action': 'Run Lua: backup.lua', 'enabled': true},
    {'name': 'Ping Server', 'schedule': 'Every 5 minutes', 'action': 'Capability: Network', 'enabled': false},
  ];

  void _showCreateTask() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 400,
        color: const Color(0xFF0C0C0E),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Create Task', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: '.SF Pro Text')),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  onSelectedItemChanged: (i) {},
                  children: const [
                    Text('Every 5 minutes', style: TextStyle(color: Colors.white)),
                    Text('Every hour', style: TextStyle(color: Colors.white)),
                    Text('Every day', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              CupertinoButton.filled(
                child: const Text('Save'),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
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
        middle: const Text('Scheduler', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600, fontFamily: '.SF Pro Text')),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _showCreateTask,
          child: const Icon(CupertinoIcons.add, color: Colors.white),
        ),
      ),
      child: SafeArea(
        child: _tasks.isEmpty
            ? const Center(
                child: Text('No scheduled tasks', style: TextStyle(color: Color(0x99FFFFFF), fontFamily: '.SF Pro Text')),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Dismissible(
                    key: Key(task['name']),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: CupertinoColors.destructiveRed,
                      child: const Icon(CupertinoIcons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => setState(() => _tasks.removeAt(index)),
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
                          child: Row(
                            children: [
                              const Icon(CupertinoIcons.timer, color: Colors.white, size: 28),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(task['name'], style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: '.SF Pro Text')),
                                    const SizedBox(height: 4),
                                    Text(task['schedule'], style: const TextStyle(color: Color(0x99FFFFFF), fontSize: 13, fontFamily: '.SF Pro Text')),
                                    const SizedBox(height: 4),
                                    Text(task['action'], style: const TextStyle(color: Color(0x99FFFFFF), fontSize: 12, fontFamily: '.SF Pro Text')),
                                  ],
                                ),
                              ),
                              CupertinoSwitch(
                                value: task['enabled'],
                                onChanged: (val) => setState(() => task['enabled'] = val),
                              )
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: (50 * index).ms).slideY(begin: 0.05),
                  );
                },
              ),
      ),
    );
  }
}
