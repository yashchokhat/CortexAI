import os
import re

directory = "cortexai_app/lib/espclaw/screens"

for filename in os.listdir(directory):
    if not filename.endswith(".dart"): continue
    
    filepath = os.path.join(directory, filename)
    with open(filepath, "r") as f:
        content = f.read()
        
    # Fix `],,`
    content = content.replace("],,", "],")
    content = content.replace("],,", "],")
    
    # Fix `body: _isLoading` to `child: _isLoading` inside Expanded
    content = content.replace("Expanded(\n              flex: 2,\n              body: _isLoading", "Expanded(\n              flex: 2,\n              child: _isLoading")
    
    # Fix `body: _modules.isEmpty` to `child: _modules.isEmpty`
    content = content.replace("body: _modules", "child: _modules")
    
    # esp_scheduler_page.dart:
    content = content.replace("Expanded(\n              body: _tasks", "Expanded(\n              child: _tasks")
    content = content.replace("Expanded(\n              body: _isLoading", "Expanded(\n              child: _isLoading")
    
    # esp_skills_page.dart:
    content = content.replace("Expanded(\n              body: _skills", "Expanded(\n              child: _skills")
    content = content.replace("Expanded(\n              body: _isLoading", "Expanded(\n              child: _isLoading")
    
    # esp_status_page.dart:
    content = content.replace("Expanded(\n              body: _isLoading", "Expanded(\n              child: _isLoading")
    
    # esp_mcp_page.dart:
    content = content.replace("Expanded(\n              body: _tools", "Expanded(\n              child: _tools")
    content = content.replace("Expanded(\n              body: _isLoading", "Expanded(\n              child: _isLoading")
    
    # esp_memory_page.dart:
    content = content.replace("Expanded(\n              body: _memories", "Expanded(\n              child: _memories")
    content = content.replace("Expanded(\n              body: _isLoading", "Expanded(\n              child: _isLoading")
    
    # Fix double closing parenthesis if any
    
    # Replace ESP-Claw with Vertex Agent ESP
    content = content.replace("ESP-Claw", "Vertex Agent ESP")
    
    with open(filepath, "w") as f:
        f.write(content)
