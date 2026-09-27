class DeviceStatus {
  final String deviceName;
  final String firmwareVersion;
  final int uptime;
  final int freeHeap;
  final int wifiRssi;
  final String ipAddress;
  final String chipInfo;
  final int capabilitiesCount;

  DeviceStatus({
    required this.deviceName,
    required this.firmwareVersion,
    required this.uptime,
    required this.freeHeap,
    required this.wifiRssi,
    required this.ipAddress,
    required this.chipInfo,
    required this.capabilitiesCount,
  });

  factory DeviceStatus.fromJson(Map<String, dynamic> json) {
    return DeviceStatus(
      deviceName: json['deviceName']?.toString() ?? '',
      firmwareVersion: json['firmwareVersion']?.toString() ?? '',
      uptime: json['uptime'] as int? ?? 0,
      freeHeap: json['freeHeap'] as int? ?? 0,
      wifiRssi: json['wifiRssi'] as int? ?? 0,
      ipAddress: json['ipAddress']?.toString() ?? '',
      chipInfo: json['chipInfo']?.toString() ?? '',
      capabilitiesCount: json['capabilitiesCount'] as int? ?? 0,
    );
  }
}
