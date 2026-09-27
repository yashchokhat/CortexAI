class EspClawDevice {
  final String name;
  final String ip;
  final int httpPort;
  final int mcpPort;
  final String chip;
  final String status;

  EspClawDevice({
    required this.name,
    required this.ip,
    this.httpPort = 80,
    this.mcpPort = 18791,
    this.chip = '',
    this.status = 'offline',
  });

  EspClawDevice copyWith({
    String? name,
    String? ip,
    int? httpPort,
    int? mcpPort,
    String? chip,
    String? status,
  }) {
    return EspClawDevice(
      name: name ?? this.name,
      ip: ip ?? this.ip,
      httpPort: httpPort ?? this.httpPort,
      mcpPort: mcpPort ?? this.mcpPort,
      chip: chip ?? this.chip,
      status: status ?? this.status,
    );
  }

  String get baseUrl => 'http://$ip${httpPort == 80 ? "" : ":$httpPort"}';
}
