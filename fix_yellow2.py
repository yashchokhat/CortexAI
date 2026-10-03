import os
import re

directory = "cortexai_app/lib/espclaw/screens"

for filename in os.listdir(directory):
    if not filename.endswith(".dart"): continue
    if filename in ["esp_chat_page.dart", "esp_dashboard_page.dart", "device_discovery_page.dart"]: continue
    
    filepath = os.path.join(directory, filename)
    with open(filepath, "r") as f:
        content = f.read()
        
    # Replace border: null,
    content = content.replace("border: null,", "")
    
    # Replace child: SafeArea( with body: SafeArea( for Scaffold
    # Wait, the word "child:" might be used elsewhere. We only want the top-level one for Scaffold.
    # The structure is usually:
    # Scaffold(
    #   backgroundColor: ...,
    #   appBar: AppBar(...),
    #   child: SafeArea( ...
    # We can use regex to replace the first `child:` after `AppBar(` that is at the same indentation level, 
    # but the simplest is just `      child: SafeArea(` -> `      body: SafeArea(`
    content = content.replace("      child: SafeArea(", "      body: SafeArea(")
    
    with open(filepath, "w") as f:
        f.write(content)
