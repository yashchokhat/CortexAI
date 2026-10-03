import re

with open("cortexai_app/lib/espclaw/screens/esp_chat_page.dart", "r") as f:
    content = f.read()

# 1. Fix id and agent
content = re.sub(r"id: map\['id'\],\n\s*", "", content)
content = re.sub(r"'id': m\.id,\n\s*", "", content)
content = content.replace("MessageSender.agent", "MessageSender.assistant")
content = content.replace("'agent'", "'assistant'")

# 2. Add _saveMessages() to all scrollToBottom() calls
content = re.sub(r"(\s+)(scrollToBottom\(\);)", r"\1_saveMessages();\1\2", content)
# But wait, we might duplicate if already added. Let's remove them first.
content = content.replace("_saveMessages();\n          _saveMessages();\n", "_saveMessages();\n")
content = content.replace("_saveMessages();\n    _saveMessages();\n", "_saveMessages();\n")

# 3. Remove duplicate imports
content = content.replace("import 'package:flutter/material.dart';\nimport 'package:shared_preferences/shared_preferences.dart';\nimport 'dart:convert';\n\nimport 'package:shared_preferences/shared_preferences.dart';\nimport 'dart:convert';", "import 'package:flutter/material.dart';\nimport 'package:shared_preferences/shared_preferences.dart';\nimport 'dart:convert';")

with open("cortexai_app/lib/espclaw/screens/esp_chat_page.dart", "w") as f:
    f.write(content)
print("Done")
