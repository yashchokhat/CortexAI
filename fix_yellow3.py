import os

directory = "cortexai_app/lib/espclaw/screens"

for filename in os.listdir(directory):
    if not filename.endswith(".dart"): continue
    if filename in ["esp_chat_page.dart", "esp_dashboard_page.dart", "device_discovery_page.dart"]: continue
    
    filepath = os.path.join(directory, filename)
    with open(filepath, "r") as f:
        content = f.read()
        
    # Undo the bad title: replacement
    # We replaced `middle:` with `title:`, then `title:` with `centerTitle: true,\n        title:`
    # This means everything that was `middle:` became `centerTitle: true,\n        title:`
    # And everything that was ALREADY `title:` also became `centerTitle: true,\n        title:`
    
    # Actually, we want to change `centerTitle: true,\n        title:` back to `title:` EXCEPT for the AppBar.
    # The AppBar title is usually around `        centerTitle: true,\n        title: const Text(`
    # Let's just restore from git for these files and do it properly!
