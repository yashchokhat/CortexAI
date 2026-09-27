import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../services/connection_manager.dart';

class EspConfigPage extends StatefulWidget {
  const EspConfigPage({super.key});

  @override
  State<EspConfigPage> createState() => _EspConfigPageState();
}

class _EspConfigPageState extends State<EspConfigPage> {
  bool _isLoading = true;
  bool _obscureWifiPassword = true;
  bool _obscureApiKey = true;
  bool _obscureSearchKey = true;

  final TextEditingController _wifiSsidCtrl = TextEditingController();
  final TextEditingController _wifiPwdCtrl = TextEditingController();

  final TextEditingController _llmBackendCtrl = TextEditingController();
  final TextEditingController _llmModelCtrl = TextEditingController();
  final TextEditingController _llmApiKeyCtrl = TextEditingController();
  final TextEditingController _llmBaseUrlCtrl = TextEditingController();
  final TextEditingController _llmMaxTokensCtrl = TextEditingController();

  final TextEditingController _searchBraveKeyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchConfig();
  }

  Future<void> _fetchConfig() async {
    setState(() => _isLoading = true);
    
    try {
      final client = ConnectionManager.instance.api;
      if (client != null) {
        final config = await client.getConfig();
        _wifiSsidCtrl.text = config['wifi_ssid']?.toString() ?? '';
        _wifiPwdCtrl.text = config['wifi_password']?.toString() ?? '';
        _llmBackendCtrl.text = config['llm_backend_type']?.toString() ?? '';
        _llmModelCtrl.text = config['llm_model']?.toString() ?? '';
        _llmApiKeyCtrl.text = config['llm_api_key']?.toString() ?? '';
        _llmBaseUrlCtrl.text = config['llm_base_url']?.toString() ?? '';
        _llmMaxTokensCtrl.text = config['llm_max_tokens']?.toString() ?? '';
        _searchBraveKeyCtrl.text = config['search_brave_key']?.toString() ?? '';
      }
    } catch (e) {
      debugPrint("Failed to fetch config: $e");
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _saveConfig() async {
    try {
      final client = ConnectionManager.instance.api;
      if (client == null) throw Exception("Device not connected");

      await client.postConfig({
        'wifi_ssid': _wifiSsidCtrl.text.trim(),
        'wifi_password': _wifiPwdCtrl.text.trim(),
        'llm_backend_type': _llmBackendCtrl.text.trim(),
        'llm_model': _llmModelCtrl.text.trim(),
        'llm_api_key': _llmApiKeyCtrl.text.trim(),
        'llm_base_url': _llmBaseUrlCtrl.text.trim(),
        'llm_max_tokens': _llmMaxTokensCtrl.text.trim(),
        'search_brave_key': _searchBraveKeyCtrl.text.trim(),
      });

      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Success'),
            content: const Text('Configuration saved to device. Restart device to apply changes.'),
            actions: [
              CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.pop(context))
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('Failed to save configuration: $e'),
            actions: [
              CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.pop(context))
            ],
          ),
        );
      }
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isObscure = false, Widget? suffix}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0x99FFFFFF), fontSize: 13, fontFamily: '.SF Pro Text')),
          const SizedBox(height: 6),
          CupertinoTextField(
            controller: controller,
            obscureText: isObscure,
            style: const TextStyle(color: Colors.white, fontFamily: '.SF Pro Text'),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF141416),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x28FFFFFF)),
            ),
            suffix: suffix,
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required String title, required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0C0C0E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x28FFFFFF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, fontFamily: '.SF Pro Text')),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05);
  }

  @override
  void dispose() {
    _wifiSsidCtrl.dispose();
    _wifiPwdCtrl.dispose();
    _llmBackendCtrl.dispose();
    _llmModelCtrl.dispose();
    _llmApiKeyCtrl.dispose();
    _llmBaseUrlCtrl.dispose();
    _llmMaxTokensCtrl.dispose();
    _searchBraveKeyCtrl.dispose();
    super.dispose();
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
        middle: const Text('Configuration', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600, fontFamily: '.SF Pro Text')),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isLoading ? null : _saveConfig,
          child: const Text('Save', style: TextStyle(color: CupertinoColors.activeBlue, fontWeight: FontWeight.bold)),
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildGlassCard(
                    title: 'Wi-Fi Network',
                    child: Column(
                      children: [
                        _buildTextField('SSID', _wifiSsidCtrl),
                        _buildTextField('Password', _wifiPwdCtrl, isObscure: _obscureWifiPassword, suffix: CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Icon(_obscureWifiPassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash, color: Colors.white),
                          onPressed: () => setState(() => _obscureWifiPassword = !_obscureWifiPassword),
                        )),
                      ],
                    ),
                  ),
                  _buildGlassCard(
                    title: 'Core LLM Engine',
                    child: Column(
                      children: [
                        _buildTextField('Backend Type (e.g. openai)', _llmBackendCtrl),
                        _buildTextField('Model Name (e.g. gpt-4o)', _llmModelCtrl),
                        _buildTextField('API Key', _llmApiKeyCtrl, isObscure: _obscureApiKey, suffix: CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Icon(_obscureApiKey ? CupertinoIcons.eye : CupertinoIcons.eye_slash, color: Colors.white),
                          onPressed: () => setState(() => _obscureApiKey = !_obscureApiKey),
                        )),
                        _buildTextField('Base URL', _llmBaseUrlCtrl),
                        _buildTextField('Max Tokens', _llmMaxTokensCtrl),
                      ],
                    ),
                  ),
                  _buildGlassCard(
                    title: 'Search Skill',
                    child: Column(
                      children: [
                        _buildTextField('Brave API Key', _searchBraveKeyCtrl, isObscure: _obscureSearchKey, suffix: CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Icon(_obscureSearchKey ? CupertinoIcons.eye : CupertinoIcons.eye_slash, color: Colors.white),
                          onPressed: () => setState(() => _obscureSearchKey = !_obscureSearchKey),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  CupertinoButton.filled(
                    onPressed: _saveConfig,
                    child: const Text('Save to Device', style: TextStyle(fontWeight: FontWeight.bold)),
                  ).animate().fadeIn().slideY(),
                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }
}
