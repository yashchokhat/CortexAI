import re

with open("cortexai_app/lib/espclaw/screens/esp_chat_page.dart", "r") as f:
    content = f.read()

send_msg_old = """      messages.add(msg);
    });

    _scrollToBottom();"""

send_msg_new = """      messages.add(msg);
    });
    _saveMessages();
    _scrollToBottom();"""

content = content.replace(send_msg_old, send_msg_new)

with open("cortexai_app/lib/espclaw/screens/esp_chat_page.dart", "w") as f:
    f.write(content)
print("Updated sendMessage")
