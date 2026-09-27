import 'dart:io';
import 'dart:convert';

void main() async {
  final client = HttpClient();
  try {
    final uri = Uri.parse('http://192.168.1.6/api/webim/send');
    final request = await client.postUrl(uri);
    final jsonString = jsonEncode({'chat_id': 'default', 'text': 'test from dart'});
    final bytes = utf8.encode(jsonString);
    request.headers.contentType = ContentType.json;
    request.headers.contentLength = bytes.length;
    request.add(bytes);
    
    final response = await request.close();
    print('Status: ${response.statusCode}');
    final body = await response.transform(utf8.decoder).join();
    print('Body: $body');
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
