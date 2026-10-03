import 'dart:convert';
import 'dart:io';

class EspClawApi {
  final String ip;
  final HttpClient _client;
  static const Duration _timeout = Duration(seconds: 4);

  EspClawApi({required this.ip}) : _client = HttpClient() {
    _client.connectionTimeout = _timeout;
  }

  String get baseUrl => 'http://$ip';

  Future<Map<String, dynamic>> getStatus() async {
    return await _get('/api/status');
  }

  Future<Map<String, dynamic>> getConfig() async {
    return await _get('/api/config');
  }

  Future<Map<String, dynamic>> postConfig(
    Map<String, dynamic> body, {
    String? path,
  }) async {
    return await _post(path ?? '/api/config', body);
  }

  Future<Map<String, dynamic>> postData(
    String path,
    Map<String, dynamic> body,
  ) async {
    return await _post(path, body);
  }

  Future<List<dynamic>> getCapabilities() async {
    final res = await _get('/api/capabilities');
    return res is List ? res : (res['items'] ?? []);
  }

  Future<void> restart() async {
    await _post('/api/restart', {});
  }

  Future<List<dynamic>> getFiles(String path) async {
    final res = await _get('/api/files?path=${Uri.encodeQueryComponent(path)}');
    return res is List ? res : (res['entries'] ?? []);
  }

  Future<void> uploadFile(String path, List<int> bytes) async {
    final uri = Uri.parse(
      '$baseUrl/api/files/upload?path=${Uri.encodeQueryComponent(path)}',
    );
    final request = await _client.postUrl(uri);
    request.add(bytes);
    final response = await request.close().timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('Failed to upload file: ${response.statusCode}');
    }
  }

  Future<void> mkdir(String path) async {
    await _post('/api/files/mkdir', {'path': path});
  }

  Future<void> deleteFile(String path) async {
    final uri = Uri.parse(
      '$baseUrl/api/files?path=${Uri.encodeQueryComponent(path)}',
    );
    final request = await _client.deleteUrl(uri);
    final response = await request.close().timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete file: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> getLuaModules() async {
    final res = await _get('/api/lua-modules');
    return res is List ? res : (res['modules'] ?? []);
  }

  Future<bool> healthCheck() async {
    try {
      final uri = Uri.parse('$baseUrl/api/status');
      final request = await _client.getUrl(uri);
      final response = await request.close().timeout(_timeout);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<dynamic> _get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = await _client.getUrl(uri);
    final response = await request.close().timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('GET $path failed with status ${response.statusCode}');
    }
    final body = await response.transform(utf8.decoder).join();
    return jsonDecode(body);
  }

  Future<dynamic> _post(String path, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = await _client.postUrl(uri);
    final jsonString = jsonEncode(data);
    final bytes = utf8.encode(jsonString);
    request.headers.contentType = ContentType.json;
    request.headers.contentLength = bytes.length;
    request.add(bytes);

    final response = await request.close().timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('POST $path failed with status ${response.statusCode}');
    }
    final body = await response.transform(utf8.decoder).join();
    if (body.isEmpty) return {};
    return jsonDecode(body);
  }
}
