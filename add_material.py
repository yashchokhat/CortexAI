import os
import glob
import re

for filepath in glob.glob("cortexai_app/lib/espclaw/screens/*.dart"):
    with open(filepath, "r") as f:
        content = f.read()
    
    # Check if we have CupertinoPageScaffold or CupertinoTheme
    if "return CupertinoPageScaffold(" in content:
        content = content.replace("return CupertinoPageScaffold(", "return Material(type: MaterialType.transparency, child: CupertinoPageScaffold(")
        content = re.sub(r";\n  }\n}", r");\n  }\n}", content)
    elif "return CupertinoTheme(" in content:
        content = content.replace("return CupertinoTheme(", "return Material(type: MaterialType.transparency, child: CupertinoTheme(")
        content = re.sub(r";\n  }\n}", r");\n  }\n}", content)
        
    with open(filepath, "w") as f:
        f.write(content)

print("done")
