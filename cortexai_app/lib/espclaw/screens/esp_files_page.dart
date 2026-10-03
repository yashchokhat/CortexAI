import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/connection_manager.dart';

class EspFilesPage extends StatefulWidget {
  final String path;
  const EspFilesPage({super.key, this.path = '/'});

  @override
  State<EspFilesPage> createState() => _EspFilesPageState();
}

class _EspFilesPageState extends State<EspFilesPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _files = [];

  @override
  void initState() {
    super.initState();
    _fetchFiles();
  }

  Future<void> _fetchFiles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final client = ConnectionManager.instance.api;
      if (client != null) {
        final files = await client.getFiles(widget.path);
        if (mounted) {
          setState(() {
            _files = files;
          });
        }
      } else {
        throw Exception("Device not connected");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteFile(String name, bool isDir) async {
    final client = ConnectionManager.instance.api;
    if (client == null) return;

    final pathToDelete = widget.path.endsWith('/')
        ? '${widget.path}$name'
        : '${widget.path}/$name';
    try {
      await client.deleteFile(pathToDelete);
      _fetchFiles();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
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
            'File Manager',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              fontFamily: '.SF Pro Text',
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF330000),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x55FF3B30)),
              ),
              child: const Row(
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_triangle_fill,
                    color: CupertinoColors.destructiveRed,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Modifying system files can affect device behavior',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontFamily: '.SF Pro Text',
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.folder,
                    color: Color(0x99FFFFFF),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.path,
                    style: const TextStyle(
                      color: Color(0x99FFFFFF),
                      fontSize: 15,
                      fontFamily: '.SF Pro Text',
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CupertinoActivityIndicator(radius: 14))
                  : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.exclamationmark_circle,
                            color: CupertinoColors.destructiveRed,
                            size: 40,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Failed to load files',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: '.SF Pro Text',
                            ),
                          ),
                          const SizedBox(height: 16),
                          CupertinoButton(
                            color: const Color(0x28FFFFFF),
                            onPressed: _fetchFiles,
                            child: const Text(
                              'Retry',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _files.isEmpty
                  ? const Center(
                      child: Text(
                        'Empty directory',
                        style: TextStyle(
                          color: Color(0x99FFFFFF),
                          fontFamily: '.SF Pro Text',
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _files.length,
                      itemBuilder: (context, index) {
                        final file = _files[index] as Map<String, dynamic>;
                        final isDir = file['is_dir'] == true;
                        final name = file['name']?.toString() ?? 'unknown';
                        final size = file['size']?.toString() ?? '0';

                        return Dismissible(
                              key: Key(name),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (direction) async {
                                return await showCupertinoDialog<bool>(
                                  context: context,
                                  builder: (context) => CupertinoAlertDialog(
                                    title: const Text('Delete File?'),
                                    content: Text(
                                      'Are you sure you want to delete $name?',
                                    ),
                                    actions: [
                                      CupertinoDialogAction(
                                        child: const Text('Cancel'),
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                      ),
                                      CupertinoDialogAction(
                                        isDestructiveAction: true,
                                        child: const Text('Delete'),
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (direction) {
                                _deleteFile(name, isDir);
                              },
                              background: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.destructiveRed,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(
                                  CupertinoIcons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              child: GestureDetector(
                                onTap: isDir
                                    ? () {
                                        final newPath =
                                            widget.path.endsWith('/')
                                            ? '${widget.path}$name/'
                                            : '${widget.path}/$name/';
                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (_) =>
                                                EspFilesPage(path: newPath),
                                          ),
                                        );
                                      }
                                    : null,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0C0C0E),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0x28FFFFFF),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isDir
                                            ? CupertinoIcons.folder_fill
                                            : CupertinoIcons.doc_text_fill,
                                        color: isDir
                                            ? CupertinoColors.activeBlue
                                            : const Color(0xFFE5E5EA),
                                        size: 28,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: '.SF Pro Text',
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              isDir ? 'Folder' : '$size bytes',
                                              style: const TextStyle(
                                                color: Color(0x99FFFFFF),
                                                fontSize: 13,
                                                fontFamily: '.SF Pro Text',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isDir)
                                        const Icon(
                                          CupertinoIcons.chevron_right,
                                          color: Color(0x4DFFFFFF),
                                          size: 16,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 200.ms, delay: (index * 50).ms)
                            .slideX(begin: 0.1);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
