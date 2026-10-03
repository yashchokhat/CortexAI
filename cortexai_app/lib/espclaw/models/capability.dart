class Capability {
  final String name;
  final String group;
  final bool enabled;

  Capability({required this.name, required this.group, required this.enabled});

  factory Capability.fromJson(Map<String, dynamic> json) {
    return Capability(
      name: json['name']?.toString() ?? '',
      group: json['group']?.toString() ?? '',
      enabled: json['enabled'] as bool? ?? false,
    );
  }

  static List<Capability> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((json) => Capability.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
