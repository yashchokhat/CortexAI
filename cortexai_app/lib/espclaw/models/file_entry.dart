class FileEntry {
  final String name;
  final String path;
  final bool isDirectory;
  final int size;
  final DateTime? modifiedDate;

  FileEntry({
    required this.name,
    required this.path,
    required this.isDirectory,
    required this.size,
    this.modifiedDate,
  });

  factory FileEntry.fromJson(Map<String, dynamic> json) {
    return FileEntry(
      name: json['name']?.toString() ?? '',
      path: json['path']?.toString() ?? '',
      isDirectory: json['isDirectory'] as bool? ?? false,
      size: json['size'] as int? ?? 0,
      modifiedDate: json['modifiedDate'] != null 
          ? DateTime.tryParse(json['modifiedDate'].toString()) 
          : null,
    );
  }
}
