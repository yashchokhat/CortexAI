import os
import glob
import re

for filepath in glob.glob("cortexai_app/lib/espclaw/screens/*.dart"):
    with open(filepath, "r") as f:
        content = f.read()
    
    # Add DefaultTextStyle for CupertinoTheme fallback
    if "CupertinoTheme(" in content and "DefaultTextStyle" not in content:
        # Wrap Scaffold or CupertinoPageScaffold in DefaultTextStyle
        # Actually it's easier to just replace CupertinoPageScaffold with Scaffold
        content = content.replace("CupertinoPageScaffold(", "Scaffold(backgroundColor: const Color(0xFF000000), body: ")
        # In EspConfigPage we have navigationBar: CupertinoNavigationBar(
        if "navigationBar:" in content:
            content = content.replace("navigationBar:", "appBar: ")
            content = content.replace("CupertinoNavigationBar(", "AppBar(backgroundColor: Colors.transparent, elevation: 0, ")
            # fix middle: to title:
            content = content.replace("middle: const Text", "title: const Text")
            # fix trailing: to actions:
            content = re.sub(r"trailing: (.*?),\n      child:", r"actions: [\1],\n      body:", content, flags=re.DOTALL)
            
    # Also wrap body with DefaultTextStyle just in case CupertinoTheme doesn't do it
    if "child: Scaffold(" in content:
        content = content.replace("child: Scaffold(", "child: DefaultTextStyle(style: const TextStyle(color: Colors.white, decoration: TextDecoration.none, fontFamily: '.SF Pro Text'), child: Scaffold(")
    elif "child: PopScope(" in content:
        content = content.replace("child: PopScope(", "child: DefaultTextStyle(style: const TextStyle(color: Colors.white, decoration: TextDecoration.none, fontFamily: '.SF Pro Text'), child: PopScope(")
        
    with open(filepath, "w") as f:
        f.write(content)

print("done")
