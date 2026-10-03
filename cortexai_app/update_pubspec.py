import re

with open("pubspec.yaml", "r") as f:
    content = f.read()

launcher_icons_config = """
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/icon.png"
"""

if "flutter_launcher_icons:" not in content:
    dev_deps_idx = content.find("dev_dependencies:")
    if dev_deps_idx != -1:
        # Add dependency
        content = content.replace("dev_dependencies:", "dev_dependencies:\n  flutter_launcher_icons: ^0.14.1")
        # Append config
        content += "\n" + launcher_icons_config
        with open("pubspec.yaml", "w") as f:
            f.write(content)
        print("Added flutter_launcher_icons config")
