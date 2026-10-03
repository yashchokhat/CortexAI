import os

directory = "cortexai_app/lib/espclaw/screens"

for filename in os.listdir(directory):
    if not filename.endswith(".dart"): continue
    if filename in ["esp_chat_page.dart", "esp_dashboard_page.dart", "device_discovery_page.dart"]: continue
    
    filepath = os.path.join(directory, filename)
    with open(filepath, "r") as f:
        content = f.read()
        
    # Replace all occurrences of "centerTitle: true,\n        title:" with "title:"
    content = content.replace("centerTitle: true,\n        title:", "title:")
    
    # Now explicitly add centerTitle: true ONLY to AppBar
    content = content.replace("appBar: AppBar(\n        elevation: 0,", "appBar: AppBar(\n        elevation: 0,\n        centerTitle: true,")
    
    # Also fix "child: SafeArea" if any are left
    content = content.replace("      child: SafeArea(", "      body: SafeArea(")
    content = content.replace("      child: _isLoading", "      body: _isLoading")
    content = content.replace("      child: _modules", "      body: _modules")
    
    with open(filepath, "w") as f:
        f.write(content)
