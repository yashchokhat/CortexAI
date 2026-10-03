import re

with open("cortexai_app/lib/espclaw/screens/esp_config_page.dart", "r") as f:
    content = f.read()
content = content.replace("child: SafeArea(", "body: SafeArea(")
content = content.replace("body: _isLoading\n            ?", "child: _isLoading\n            ?")
with open("cortexai_app/lib/espclaw/screens/esp_config_page.dart", "w") as f:
    f.write(content)

with open("cortexai_app/lib/espclaw/screens/esp_files_page.dart", "r") as f:
    content = f.read()
# esp_files_page already had Scaffold natively. But we changed body: SafeArea to child: SafeArea or something?
content = content.replace("child: SafeArea(", "body: SafeArea(")
content = content.replace("body: Column(", "child: Column(")
with open("cortexai_app/lib/espclaw/screens/esp_files_page.dart", "w") as f:
    f.write(content)
    
with open("cortexai_app/lib/espclaw/screens/esp_scheduler_page.dart", "r") as f:
    content = f.read()
# line 25 is outside build! It's probably in a widget like `Container(body: ...)`
# Wait, my script changed `body:` to `child:` globally, so line 25 must have been `body:` originally! But my script changed it to `child:`! Oh wait, `body: ...` on line 25 might have been changed to `child:`, but wait, the error is `The named parameter 'body' isn't defined`! So my script DID NOT change it, or my script CHANGED `child:` to `body:` on line 25!
# My script did `content.replace("child: SafeArea(", "body: SafeArea(")` but I had `content = content.replace("body:", "child:")` BEFORE that. Wait, if it changed it to `child:`, then the error would NOT be `body isn't defined`!
