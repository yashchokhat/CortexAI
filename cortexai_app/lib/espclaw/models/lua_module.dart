class LuaModule {
  final String name;
  final String description;
  final bool enabled;
  final String version;

  LuaModule({
    required this.name,
    required this.description,
    required this.enabled,
    required this.version,
  });

  factory LuaModule.fromJson(Map<String, dynamic> json) {
    return LuaModule(
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      enabled: json['enabled'] as bool? ?? false,
      version: json['version']?.toString() ?? '',
    );
  }
}
