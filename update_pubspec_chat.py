import re

with open("cortexai_app/pubspec.yaml", "r") as f:
    content = f.read()

if "shared_preferences:" not in content:
    deps_idx = content.find("dependencies:")
    if deps_idx != -1:
        content = content.replace("dependencies:\n", "dependencies:\n  shared_preferences: ^2.2.3\n")
        with open("cortexai_app/pubspec.yaml", "w") as f:
            f.write(content)
        print("Added shared_preferences")
