import os
import re

directory = "cortexai_app/lib/espclaw/screens"

for filename in os.listdir(directory):
    if not filename.endswith(".dart"): continue
    
    filepath = os.path.join(directory, filename)
    with open(filepath, "r") as f:
        content = f.read()
        
    if "CupertinoPageScaffold" in content:
        # Replace CupertinoPageScaffold with Scaffold
        content = content.replace("CupertinoPageScaffold(", "Scaffold(")
        
        # Replace navigationBar: CupertinoNavigationBar( with appBar: AppBar(
        content = content.replace("navigationBar: CupertinoNavigationBar(", "appBar: AppBar(\n        elevation: 0,")
        
        # Replace middle: with title:
        content = content.replace("middle:", "title:")
        
        # Replace trailing: with actions: [ ... ]
        # This requires regex or careful matching
        def trailing_repl(match):
            trailing_content = match.group(1)
            return f"actions: [{trailing_content}],"
        content = re.sub(r'trailing:\s*(.*?),\n      \)', trailing_repl, content, flags=re.DOTALL)
        
        # Also need to add centerTitle: true to AppBar
        content = content.replace("title:", "centerTitle: true,\n        title:")
        
        with open(filepath, "w") as f:
            f.write(content)
