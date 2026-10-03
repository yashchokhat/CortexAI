import os
import re

directory = "cortexai_app/lib/espclaw/screens"

for filename in os.listdir(directory):
    if not filename.endswith(".dart"): continue
    if filename in ["esp_chat_page.dart", "esp_dashboard_page.dart", "device_discovery_page.dart"]: continue
    
    filepath = os.path.join(directory, filename)
    with open(filepath, "r") as f:
        content = f.read()
        
    # Replace all body: with child:
    content = content.replace("body:", "child:")
    
    # But Scaffold requires body:. The Scaffold is usually:
    # appBar: ...
    # child: SafeArea(
    # Let's replace `child: SafeArea(` with `body: SafeArea(`
    content = content.replace("child: SafeArea(", "body: SafeArea(")
    
    # In esp_config_page.dart, there is no Expanded inside SafeArea, it's just child: _isLoading
    content = content.replace("child: _isLoading\n            ?", "body: _isLoading\n            ?")
    
    with open(filepath, "w") as f:
        f.write(content)
