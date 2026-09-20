import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/api_service.dart';
import 'widgets/glass_template_card.dart';

class TemplateActionPage extends StatefulWidget {
  final Template template;
  final int index;

  const TemplateActionPage({
    super.key,
    required this.template,
    required this.index,
  });

  @override
  State<TemplateActionPage> createState() => _TemplateActionPageState();
}

class _TemplateActionPageState extends State<TemplateActionPage> {
  bool _isUploading = false;

  void _handleUpload() async {
    setState(() => _isUploading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isUploading = false);
    
    // Show success dialog
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoTheme(
        data: const CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.white,
        ),
        child: CupertinoAlertDialog(
          title: const Text('Upload Complete', style: TextStyle(color: Colors.white)),
          content: const Text('Routine deployed to edge node successfully.', style: TextStyle(color: Color(0xCCFFFFFF))),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Color(0xFF000000),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          decoration: TextDecoration.none,
          color: Colors.white,
          fontFamily: '.SF Pro Text',
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFF000000),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Deploy Template',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Hero(
                  tag: 'template_card_${widget.template.id}',
                  child: Material(
                    type: MaterialType.transparency,
                    child: GlassTemplateCard(
                      template: widget.template,
                      index: widget.index,
                      onTap: () {},
                      height: 180, // Compact height for header
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Details Section
                const Text(
                  'Configuration',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C0C0E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x28FFFFFF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Target', 'ESP32-S3 Edge Node'),
                      const Divider(color: Color(0x1AFFFFFF), height: 32),
                      _buildDetailRow('Routine', widget.template.title),
                      const Divider(color: Color(0x1AFFFFFF), height: 32),
                      _buildDetailRow('Expected Latency', '< 15ms'),
                      const Divider(color: Color(0x1AFFFFFF), height: 32),
                      _buildDetailRow('Mode', 'Continuous'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Upload Button
                GestureDetector(
                  onTap: _isUploading ? null : _handleUpload,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33FFFFFF),
                          blurRadius: 20,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isUploading
                          ? const CupertinoActivityIndicator(color: Colors.black)
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.cloud_upload_fill, color: Colors.black, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Upload & Deploy',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0x99FFFFFF),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
