import re

with open("cortexai_app/lib/espclaw/screens/esp_chat_page.dart", "r") as f:
    content = f.read()

content = content.replace("      messages.add(msg);\n    });\n    scrollToBottom();", "      messages.add(msg);\n    });\n    _saveMessages();\n    scrollToBottom();")
content = content.replace("        messages.add(msg);\n      }\n    });\n    scrollToBottom();", "        messages.add(msg);\n      }\n    });\n    _saveMessages();\n    scrollToBottom();")

with open("cortexai_app/lib/espclaw/screens/esp_chat_page.dart", "w") as f:
    f.write(content)
