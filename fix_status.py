with open("cortexai_app/lib/espclaw/screens/esp_status_page.dart", "r") as f:
    content = f.read()

content = content.replace("        child: RefreshIndicator(\n          onRefresh: _fetchStatus,\n          color: Colors.white,\n          backgroundColor: const Color(0xFF1C1C1E),\n          body: _isLoading", "        body: RefreshIndicator(\n          onRefresh: _fetchStatus,\n          color: Colors.white,\n          backgroundColor: const Color(0xFF1C1C1E),\n          child: _isLoading")

with open("cortexai_app/lib/espclaw/screens/esp_status_page.dart", "w") as f:
    f.write(content)
