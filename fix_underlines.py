import glob

for filepath in glob.glob("cortexai_app/lib/espclaw/screens/*.dart"):
    with open(filepath, "r") as f:
        content = f.read()
    
    # 1. DeviceDiscoveryPage & EspCapabilitiesPage & EspDashboardPage use CupertinoTheme(child: Scaffold( or PopScope
    content = content.replace("child: Scaffold(", "child: DefaultTextStyle(style: const TextStyle(decoration: TextDecoration.none, color: Colors.white, fontFamily: '.SF Pro Text'), child: Scaffold(")
    content = content.replace("child: PopScope(", "child: DefaultTextStyle(style: const TextStyle(decoration: TextDecoration.none, color: Colors.white, fontFamily: '.SF Pro Text'), child: PopScope(")
    
    # 2. EspConfigPage, EspStatusPage, etc use CupertinoPageScaffold at the root.
    content = content.replace("return CupertinoPageScaffold(", "return DefaultTextStyle(style: const TextStyle(decoration: TextDecoration.none, color: Colors.white, fontFamily: '.SF Pro Text'), child: CupertinoPageScaffold(")
    
    # We must balance the `DefaultTextStyle` parentheses.
    # For `child: Scaffold(`, it closes at the end of the `CupertinoTheme`.
    # Let's just find the `Widget build(BuildContext context)` block and balance parentheses!
    
