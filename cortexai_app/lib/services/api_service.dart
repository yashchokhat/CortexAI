import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class SystemStatus {
  final String system;
  final String status;
  final int totalDevices;
  final int onlineDevices;
  final int activePipelines;
  final double cpuLoadPercent;
  final double memoryUsedMb;
  final String timestamp;

  const SystemStatus({
    required this.system,
    required this.status,
    required this.totalDevices,
    required this.onlineDevices,
    required this.activePipelines,
    required this.cpuLoadPercent,
    required this.memoryUsedMb,
    required this.timestamp,
  });

  factory SystemStatus.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>? ?? {};
    return SystemStatus(
      system: json['system'] as String? ?? 'CortexAI Edge Platform',
      status: json['status'] as String? ?? 'operational',
      totalDevices: (stats['total_devices'] as num?)?.toInt() ?? 3,
      onlineDevices: (stats['online_devices'] as num?)?.toInt() ?? 2,
      activePipelines: (stats['active_pipelines'] as num?)?.toInt() ?? 1,
      cpuLoadPercent: (stats['cpu_load_percent'] as num?)?.toDouble() ?? 14.2,
      memoryUsedMb: (stats['memory_used_mb'] as num?)?.toDouble() ?? 48.5,
      timestamp: json['timestamp'] as String? ?? '',
    );
  }
}

class EdgeDevice {
  final String id;
  final String name;
  final String chip;
  final String status;
  final String ipAddress;
  final String firmwareVersion;
  final List<String> capabilities;
  final String lastSeen;

  const EdgeDevice({
    required this.id,
    required this.name,
    required this.chip,
    required this.status,
    required this.ipAddress,
    required this.firmwareVersion,
    required this.capabilities,
    required this.lastSeen,
  });

  factory EdgeDevice.fromJson(Map<String, dynamic> json) {
    final caps =
        (json['capabilities'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    return EdgeDevice(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Edge Node',
      chip: json['chip'] as String? ?? 'ESP32',
      status: json['status'] as String? ?? 'online',
      ipAddress: json['ip_address'] as String? ?? '192.168.1.1',
      firmwareVersion: json['firmware_version'] as String? ?? 'v1.0.0',
      capabilities: caps,
      lastSeen: json['last_seen'] as String? ?? '',
    );
  }
}

class Template {
  final String id;
  final String title;
  final String chip;
  final String description;
  final String icon;
  final String actionPrompt;
  final String category;

  const Template({
    required this.id,
    required this.title,
    required this.chip,
    required this.description,
    required this.icon,
    required this.actionPrompt,
    required this.category,
  });

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      chip: json['chip'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? 'sparkles',
      actionPrompt: json['action_prompt'] as String? ?? '',
      category: json['category'] as String? ?? 'Utility',
    );
  }
}

class InferenceResult {
  final String taskId;
  final String deviceId;
  final String prompt;
  final String status;
  final String response;
  final int tokensUsed;
  final int latencyMs;
  final String mode;
  final String createdAt;

  const InferenceResult({
    required this.taskId,
    required this.deviceId,
    required this.prompt,
    required this.status,
    required this.response,
    required this.tokensUsed,
    required this.latencyMs,
    required this.mode,
    required this.createdAt,
  });

  factory InferenceResult.fromJson(Map<String, dynamic> json) {
    final result = json['result'] as Map<String, dynamic>? ?? {};
    return InferenceResult(
      taskId: json['task_id'] as String? ?? '',
      deviceId: json['device_id'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
      status: json['status'] as String? ?? 'completed',
      response: result['response'] as String? ?? '',
      tokensUsed: (result['tokens_used'] as num?)?.toInt() ?? 0,
      latencyMs: (result['latency_ms'] as num?)?.toInt() ?? 0,
      mode: result['mode'] as String? ?? 'local-edge',
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://localhost:8000';
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 4);
    try {
      final uri = Uri.parse('$baseUrl$path');
      final request = await client.getUrl(uri);
      request.headers.set('Accept', 'application/json');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode == 200) {
        return jsonDecode(body) as Map<String, dynamic>;
      }
      throw HttpException('Server returned ${response.statusCode}: $body');
    } finally {
      client.close();
    }
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> payload,
  ) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 4);
    try {
      final uri = Uri.parse('$baseUrl$path');
      final request = await client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');
      request.write(jsonEncode(payload));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode == 200) {
        return jsonDecode(body) as Map<String, dynamic>;
      }
      throw HttpException('Server returned ${response.statusCode}: $body');
    } finally {
      client.close();
    }
  }

  /// Fetches system status from GET /api/v1/status
  Future<SystemStatus> fetchSystemStatus() async {
    final json = await _get('/api/v1/status');
    return SystemStatus.fromJson(json);
  }

  /// Fetches registered devices from GET /api/v1/devices
  Future<List<EdgeDevice>> fetchDevices() async {
    final json = await _get('/api/v1/devices');
    final list = json['devices'] as List<dynamic>? ?? [];
    return list
        .map((e) => EdgeDevice.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches templates from GET /api/v1/templates with fallback
  Future<List<Template>> fetchTemplates() async {
    try {
      final json = await _get('/api/v1/templates');
      final list = json['templates'] as List<dynamic>? ?? [];
      if (list.isNotEmpty) {
        return list
            .map((e) => Template.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('fetchTemplates failed, using fallback: $e');
    }

    return const [
      Template(
        id: 'tpl-led-on',
        title: 'Turn On Built-in LED',
        chip: 'GPIO',
        description: 'Energize onboard diagnostic LED.',
        icon: 'lightbulb_on',
        actionPrompt: 'Set GPIO 2 to HIGH.',
        category: 'Hardware',
      ),
      Template(
        id: 'tpl-led-off',
        title: 'Turn Off Built-in LED',
        chip: 'GPIO',
        description: 'Extinguish active LED arrays.',
        icon: 'lightbulb_off',
        actionPrompt: 'Set GPIO 2 to LOW.',
        category: 'Hardware',
      ),
      Template(
        id: 'tpl-sys-status',
        title: 'Check System Status',
        chip: 'Diagnostics',
        description: 'Get uptime, heap, and firmware details.',
        icon: 'cpu',
        actionPrompt: 'Report full system status, free heap, and uptime.',
        category: 'System',
      ),
      Template(
        id: 'tpl-scan-wifi',
        title: 'Scan WiFi Networks',
        chip: 'Network',
        description: 'Scan and list nearby APs.',
        icon: 'wifi',
        actionPrompt: 'Run a WiFi scan and list all visible networks.',
        category: 'Network',
      ),
      Template(
        id: 'tpl-clear-mem',
        title: 'Clear Cache/Memory',
        chip: 'Maintenance',
        description: 'Trigger garbage collection.',
        icon: 'trash',
        actionPrompt: 'Clear temporary caches and run garbage collection.',
        category: 'System',
      ),
      Template(
        id: 'tpl-read-temp',
        title: 'Read Temperature',
        chip: 'I2C Sensor',
        description: 'Read thermal levels.',
        icon: 'thermo',
        actionPrompt: 'Read temperature sensor data and report.',
        category: 'Sensors',
      ),
      Template(
        id: 'tpl-reboot',
        title: 'Reboot Device',
        chip: 'Power',
        description: 'Soft reboot the ESP32.',
        icon: 'restart',
        actionPrompt: 'Reboot the system safely.',
        category: 'System',
      ),
      Template(
        id: 'tpl-blink-led',
        title: 'Blink LED Pattern',
        chip: 'GPIO',
        description: 'Blink LED in an SOS pattern.',
        icon: 'flash',
        actionPrompt:
            'Blink the built-in LED in an SOS pattern (3 short, 3 long, 3 short).',
        category: 'Hardware',
      ),
      Template(
        id: 'tpl-deep-sleep',
        title: 'Deep Sleep (10s)',
        chip: 'Power',
        description: 'Enter deep sleep to save power.',
        icon: 'sleep',
        actionPrompt: 'Enter deep sleep mode for 10 seconds.',
        category: 'Power',
      ),
    ];
  }

  /// Triggers edge AI inference via POST /api/v1/inference
  Future<InferenceResult> triggerInference(
    String deviceId,
    String prompt,
  ) async {
    final payload = {'device_id': deviceId, 'prompt': prompt};
    final json = await _post('/api/v1/inference', payload);
    return InferenceResult.fromJson(json);
  }
}
