import 'dart:convert';

class ChatProtocolAdapter {
  static String extractText(dynamic data) {
    if (data is String) {
      try {
        final json = jsonDecode(data);
        if (json is Map) {
          if (json['text'] != null) {
            return json['text'].toString();
          }
          if (json['message'] != null) {
            return json['message'].toString();
          }
          if (json['content'] != null) {
            return json['content'].toString();
          }
        }
        return data;
      } catch (_) {
        return data;
      }
    }
    if (data is Map) {
      if (data['text'] != null) {
        return data['text'].toString();
      }
      if (data['message'] != null) {
        return data['message'].toString();
      }
      if (data['content'] != null) {
        return data['content'].toString();
      }
    }
    return data.toString();
  }
}
