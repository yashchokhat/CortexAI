import re
import os

directory = "cortexai_app/lib/espclaw/screens"

for filename in os.listdir(directory):
    if not filename.endswith(".dart"): continue
    
    filepath = os.path.join(directory, filename)
    with open(filepath, "r") as f:
        content = f.read()
        
    # Scaffold body is right after appBar.
    # Let's just fix the cases where body: SafeArea is inside Container or other widgets
    content = content.replace("        color: const Color(0xFF0C0C0E),\n        body: SafeArea(", "        color: const Color(0xFF0C0C0E),\n        child: SafeArea(")
    
    # esp_status_page.dart line 65
    content = content.replace("Expanded(\n              body: _isLoading", "Expanded(\n              child: _isLoading")
    # esp_status_page.dart line 69 missing child
    content = content.replace("          _isLoading\n              ? const Center", "          child: _isLoading\n              ? const Center")
    
    with open(filepath, "w") as f:
        f.write(content)
