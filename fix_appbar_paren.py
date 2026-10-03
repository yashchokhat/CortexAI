import os
import re

directory = "cortexai_app/lib/espclaw/screens"

for filename in os.listdir(directory):
    if not filename.endswith(".dart"): continue
    if filename in ["esp_chat_page.dart", "esp_dashboard_page.dart", "device_discovery_page.dart"]: continue
    
    filepath = os.path.join(directory, filename)
    with open(filepath, "r") as f:
        content = f.read()
        
    # Replace `],` before `body: SafeArea` with `],),`
    content = re.sub(r'\],(\s*)body: SafeArea\(', r'],\n      ),\1body: SafeArea(', content)
    
    # Also, some didn't have actions, so they might be missing the `)` too?
    # Wait, if they didn't have trailing, they didn't get `actions:`. They got `)`?
    # No, `trailing:` replacement was done.
    
    with open(filepath, "w") as f:
        f.write(content)
