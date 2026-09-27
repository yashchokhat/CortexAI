# ESP-Claw Custom Flutter Android App — No Backend

## 1. Goal

Build a Flutter Android application that communicates directly with an ESP32-S3 running ESP-Claw over the phone's local Wi-Fi hotspot.

**No Node.js backend, Firebase backend, cloud server, or Telegram is required for the local-control path.**

```text
┌──────────────────────┐
│ Android Phone        │
│                      │
│ Mobile Hotspot ON    │
│                      │
│ Flutter App          │
└──────────┬───────────┘
           │ Local Wi-Fi
           │
           ▼
┌──────────────────────┐
│ ESP32-S3             │
│ ESP-Claw             │
│                      │
│ HTTP Control API     │
│ Web Chat             │
│ MCP Server           │
│ Agent / LLM           │
└──────────────────────┘
```

ESP-Claw's current repository describes it as an AI-agent framework for IoT devices with LLM, IM, Lua, memory, event routing, and MCP capabilities. It supports OpenAI-style and Anthropic-style LLM APIs and custom endpoints. [1]

---

# 2. Important Architecture Decision

The phone should act as the **local network**:

```text
Phone hotspot
     │
     ├── Android / Flutter
     │
     └── ESP32-S3
```

The Flutter app should discover the ESP32 on the local subnet, identify its IP address, select the device, and then communicate directly with that IP.

Example:

```text
ESP32 IP:
192.168.43.120

Flutter requests:

GET  http://192.168.43.120/api/status
GET  http://192.168.43.120/api/config
GET  http://192.168.43.120/api/capabilities
```

For the MCP listener, the current ESP-Claw issue/source documents a default HTTP listener on port `18791` with endpoint `/mcp_server`. [2]

---

# 3. ESP-Claw Features That Can Be Controlled

The exact available capabilities depend on the ESP-Claw firmware build and which capability groups are enabled.

The current source includes capability groups for:

- Agent manager
- Files
- Feishu
- QQ
- Telegram
- WeChat
- Local/Web IM
- LLM inspection
- LLM configuration
- Lua
- MCP client
- Router manager
- Scheduler
- Session manager
- Skill manager
- System
- HTTP requests
- Web search
- Memory

The capability registry source explicitly includes these groups. [3]

## 3.1 Device Status

Flutter should provide a Device Status page.

Possible information:

- Device IP
- Device availability
- Firmware/application status
- Device capabilities
- Network status
- Runtime status
- Enabled capability groups

Endpoint:

```http
GET /api/status
```

---

# 4. Configuration Control

ESP-Claw exposes:

```http
GET /api/config
```

and:

```http
POST /api/config
```

The configuration can include LLM and IM/search configuration.

### Flutter UI

Create:

```text
Settings
├── LLM
├── IM
├── Search
├── Capability Groups
└── Device Configuration
```

### Warning

Do not display API keys unnecessarily.

The current ESP-Claw HTTP control plane has been reported as unauthenticated on the LAN, and `/api/config` can expose configuration containing credentials. Treat the local API as privileged. [2]

---

# 5. Restart Device

Endpoint:

```http
POST /api/restart
```

Flutter UI:

```text
Device
 └── Restart ESP-Claw
```

Before executing:

```text
Are you sure you want to restart ESP-Claw?

[Cancel] [Restart]
```

The restart endpoint is currently exposed by the HTTP control plane. [2]

---

# 6. Capabilities

Endpoint:

```http
GET /api/capabilities
```

Flutter should use this to determine what the connected ESP-Claw firmware supports instead of hard-coding every feature.

Example UI:

```text
Capabilities

✓ Agent
✓ Lua
✓ Files
✓ Memory
✓ Scheduler
✓ MCP
✓ Web Search
✓ HTTP Request
✓ System
✓ Skills
```

The actual list depends on the firmware configuration.

---

# 7. Lua Control

ESP-Claw has Lua module support and Lua-based device behavior.

Lua can be used to control supported hardware and device functionality.

The repository documents Lua as an extensibility mechanism and exposes Lua capability/module support. [3][4]

Flutter should provide:

```text
Lua
├── Modules
├── Scripts
├── Run Script
├── Script Result
└── Script Logs
```

Possible API-related resources:

```http
GET /api/lua-modules
```

The current HTTP control plane exposes `/api/lua-modules`. [2]

---

# 8. File Management

ESP-Claw exposes file-management APIs.

Current documented HTTP endpoints include:

```http
GET     /api/files
POST    /api/files
DELETE  /api/files
POST    /api/files/upload
POST    /api/files/mkdir
GET     /files/*
```

The current security issue documents these endpoints as providing read/write/delete access to on-device FATFS, including skills and Lua scripts. [2]

### Flutter UI

```text
Files

/
├── skills/
├── scripts/
├── config/
└── data/
```

Actions:

```text
Open
Download
Upload
Create Folder
Delete
```

### Security

This should be an administrator-only screen because file modification can affect the agent's behavior.

---

# 9. Web Chat / Local Chat

ESP-Claw includes a Web Chat/local communication path.

The current source exposes:

```http
/api/webim/*
```

and:

```text
WebSocket:
ws://<ESP_IP>/ws/webim
```

The exact sub-endpoints and message schema should be discovered from the firmware version/source rather than invented in the Flutter app. The repository changelog also documents Web Chat functionality and message-history behavior. [2][5]

## Recommended Flutter chat architecture

```text
Flutter Chat Screen
        │
        │ WebSocket
        ▼
ws://ESP_IP/ws/webim
        │
        ▼
ESP-Claw Web Chat
        │
        ▼
Agent Loop / LLM
        │
        ▼
Response
        │
        ▼
Flutter
```

This is the preferred route for a ChatGPT-like interface if the installed ESP-Claw build exposes the Web Chat WebSocket.

---

# 10. MCP

ESP-Claw supports MCP and can operate as an MCP server/client. [1]

The MCP server application documents an HTTP MCP server and the current security issue identifies:

```text
Port: 18791
Endpoint: /mcp_server
```

[2][6]

Flutter should therefore have an optional:

```text
MCP
├── Server status
├── Discover
├── List tools
├── Tool details
└── Call tool
```

However, **do not assume every MCP operation is available directly from the Flutter app**. MCP protocol handling should be implemented according to the exact ESP-Claw firmware/version.

---

# 11. MCP Client Capabilities

The ESP-Claw source defines these MCP client capabilities:

```text
mcp_list_tools
mcp_call_tool
mcp_discover
```

The source describes these as:

- remote `tools/list`
- remote `tools/call`
- local-network MCP discovery

[7]

This is useful if the ESP itself needs to discover/use other MCP devices.

---

# 12. LLM Configuration

ESP-Claw supports:

- OpenAI-style APIs
- Anthropic-style APIs
- GPT models
- Qwen
- Claude
- DeepSeek
- Custom endpoints

according to the current project README. [1]

Flutter can expose a configuration page:

```text
LLM Settings

Provider
[ OpenAI-compatible ▼ ]

Base URL
https://...

API Key
••••••••

Model
qwen...

Temperature
...

[Save]
```

Configuration should be sent to the ESP32, not stored in the Flutter application's source code.

---

# 13. Web Search

ESP-Claw includes a web-search capability group in its capability registry. [3]

Flutter can expose:

```text
AI Tools
 └── Web Search
     ├── Enabled
     └── Provider configuration
```

Actual search behavior depends on the firmware configuration and configured provider.

---

# 14. HTTP Request Capability

ESP-Claw includes an HTTP-request capability group. [3]

This allows the ESP-Claw agent to perform configured HTTP requests where supported.

Flutter can expose:

```text
Network Tools
 └── HTTP Request
```

Do not provide unrestricted arbitrary HTTP execution in the normal user interface without confirmation because it gives the agent network access.

---

# 15. Scheduler

ESP-Claw includes a scheduler capability group. [3]

Flutter can provide:

```text
Scheduler

+ Create Task

Task:
"Read temperature"

Schedule:
Every 10 minutes

Action:
Run Lua script
```

Possible application flow:

```text
Flutter
   ↓
Create scheduled task
   ↓
ESP-Claw scheduler
   ↓
Lua / capability / Agent
```

Exact scheduler API should be obtained from the installed ESP-Claw firmware/source.

---

# 16. Router / Event System

ESP-Claw's architecture includes an event router.

The project documentation describes a flow where events can trigger:

- capabilities
- scripts
- the agent
- outgoing messages
- other events
- dropping an event

[8]

Flutter can eventually provide an advanced:

```text
Automation

WHEN:
Sensor/Event

DO:
Run Lua / Agent / Capability
```

This should be considered an advanced feature.

---

# 17. Skills

ESP-Claw supports skills and skill management.

Flutter can provide:

```text
Skills

Installed
├── Environment
├── GPIO
├── Network
└── Custom

Actions
├── View
├── Enable
├── Disable
└── Upload
```

The file APIs are particularly important here because skills are stored on the device and can influence agent behavior. [2]

---

# 18. Memory

ESP-Claw includes structured memory functionality.

The README describes structured memory and emphasizes keeping memory off the cloud. [1]

Flutter UI:

```text
Memory

Search memory
─────────────

Recent memories
─────────────

[Memory item]

Delete
```

The exact memory REST API should be taken from the installed firmware/source; do not invent endpoint names.

---

# 19. Sessions / Conversation History

ESP-Claw has session/context persistence.

The changelog documents persistent context/session history and raw assistant/tool-call history. [5]

Flutter should eventually provide:

```text
Conversations

Conversation 1
Conversation 2
Conversation 3
```

However, **the current generic HTTP API list does not establish a simple `/api/chat/history` REST endpoint**.

Use the Web Chat/local channel or the appropriate internal/session API exposed by the firmware rather than assuming such an endpoint exists.

---

# 20. IM Integrations

ESP-Claw currently supports:

- Telegram
- QQ
- Feishu
- WeChat

and has a local/web channel. [1][9]

Your custom Flutter app does **not need these services for local device control**.

For your project, the preferred architecture is:

```text
Flutter
   ↓
Local Web Chat / WebSocket
   ↓
ESP-Claw Agent
```

rather than:

```text
Flutter
   ↓
Telegram
   ↓
ESP-Claw
```

---

# 21. Device Discovery

## Goal

When the user opens the Flutter app:

```text
Searching for ESP-Claw devices...

✓ ESP-Claw
  ESP32-S3
  192.168.43.120

✓ ESP-Claw
  ESP32-S3
  192.168.43.121
```

The user taps a device.

Flutter then obtains:

```text
Device IP = 192.168.43.120
```

and uses that IP for all communication.

---

# 22. Important Android Networking Reality

Android does not provide a universal API that simply returns:

```text
"all devices connected to my phone hotspot"
```

as a trusted device list.

Therefore use **local-network discovery**.

Recommended order:

### Method A — mDNS

ESP-Claw supports/advertises services through mDNS in relevant configurations. The current security report specifically notes MCP server advertisement via mDNS. [2]

Flutter can use an mDNS/Bonjour/DNS-SD package.

Conceptually:

```text
Flutter
   ↓
mDNS discovery
   ↓
_esp-claw._tcp.local
   ↓
ESP32 IP
```

### Method B — UDP discovery

If mDNS is not available/reliable on the particular firmware:

```text
Flutter
   ↓
UDP broadcast
   ↓
ESP32 discovery responder
   ↓
ESP32 returns IP/device information
```

This requires a small discovery mechanism on the ESP32 firmware.

### Method C — Subnet scan

Last-resort approach:

```text
192.168.43.1
192.168.43.2
...
192.168.43.254
```

Flutter attempts a short connection to the expected ESP-Claw service.

This is slower and should not be the primary method.

---

# 23. Flutter Package Strategy

Use a package-based discovery layer rather than manually scanning everything.

Recommended categories:

```yaml
dependencies:
  http: ^latest
  web_socket_channel: ^latest
  multicast_dns: ^latest
  network_info_plus: ^latest
```

Use:

### `network_info_plus`

For information about the Android device's network interface/local IP/subnet where supported.

### `multicast_dns`

For mDNS/DNS-SD service discovery.

### `http`

For ESP-Claw REST APIs.

### `web_socket_channel`

For the Web Chat WebSocket.

**Important:** package APIs and Android permissions can change. Pin versions compatible with the Flutter SDK used by the project rather than copying an old version blindly.

---

# 24. Android Permissions

The app should request the appropriate Android network permissions required by the Flutter packages and Android version being targeted.

At minimum, normal Internet/network access will be required for HTTP/WebSocket operations.

For newer Android versions, local-network discovery/multicast behavior may require additional handling depending on the discovery mechanism and target SDK.

Test on the actual Android phone with the hotspot enabled.

---

# 25. Device Discovery Flow

```text
App Launch
    │
    ▼
Check Wi-Fi/network state
    │
    ▼
Start mDNS discovery
    │
    ├── ESP-Claw found
    │       │
    │       ▼
    │   Resolve IP
    │
    └── Nothing found
            │
            ▼
       Optional subnet scan
            │
            ▼
       Show devices
```

Device card:

```text
┌────────────────────────────────┐
│ 🦞 ESP-Claw                    │
│                                │
│ ESP32-S3 N16R8                 │
│ 192.168.43.120                 │
│ Online                         │
│                                │
│ [Connect]                      │
└────────────────────────────────┘
```

---

# 26. After Device Selection

Once the user selects:

```text
192.168.43.120
```

store it in a device object:

```dart
class EspClawDevice {
  final String name;
  final String ip;
  final int httpPort;
  final int mcpPort;

  EspClawDevice({
    required this.name,
    required this.ip,
    this.httpPort = 80,
    this.mcpPort = 18791,
  });
}
```

Create an API client:

```dart
class EspClawApi {
  final String ip;

  EspClawApi(this.ip);

  String get baseUrl => 'http://$ip';

  String endpoint(String path) {
    return '$baseUrl$path';
  }
}
```

Now:

```dart
final api = EspClawApi(device.ip);

GET /api/status
GET /api/config
GET /api/capabilities
GET /api/lua-modules
```

---

# 27. Recommended Flutter Application Structure

```text
lib/
├── main.dart
│
├── app/
│   ├── app.dart
│   ├── routes.dart
│   └── theme.dart
│
├── models/
│   ├── esp_claw_device.dart
│   ├── capability.dart
│   ├── device_status.dart
│   └── chat_message.dart
│
├── discovery/
│   ├── mdns_discovery.dart
│   ├── subnet_discovery.dart
│   └── device_discovery_service.dart
│
├── api/
│   ├── esp_claw_api.dart
│   ├── config_api.dart
│   ├── status_api.dart
│   ├── files_api.dart
│   └── capabilities_api.dart
│
├── websocket/
│   └── web_chat_socket.dart
│
├── features/
│   ├── devices/
│   ├── chat/
│   ├── dashboard/
│   ├── capabilities/
│   ├── files/
│   ├── lua/
│   ├── skills/
│   ├── memory/
│   ├── scheduler/
│   ├── mcp/
│   └── settings/
│
└── services/
    ├── connection_manager.dart
    └── device_session.dart
```

---

# 28. Main Screens

## Screen 1 — Device Discovery

```text
ESP-Claw

Searching...

[Refresh]

Devices
────────────────────────
ESP-Claw
ESP32-S3
192.168.43.120
Online

[Connect]
```

## Screen 2 — Dashboard

```text
ESP-Claw

● Connected

ESP32-S3
192.168.43.120

Quick Actions

[Chat]
[Status]
[Capabilities]
[Files]

[Lua]
[Skills]
[Memory]

[MCP]
[Scheduler]

[Settings]
[Restart]
```

## Screen 3 — Chat

```text
ESP-Claw
● Connected

──────────────────────

You:
Turn on the LED.

ESP-Claw:
Done. The LED is now ON.

──────────────────────

[ Type a prompt...          ] [Send]
```

---

# 29. Chat Transport

Do **not** invent a REST endpoint such as:

```text
POST /api/prompt
```

unless your particular ESP-Claw build implements it.

The current source exposes Web Chat endpoints:

```text
/api/webim/*
```

and:

```text
/ws/webim
```

The current changelog confirms Web Chat functionality. [2][5]

Therefore the Flutter chat implementation should first inspect/use the Web Chat protocol supported by the exact firmware version.

---

# 30. REST API Client

Create a central HTTP client.

```dart
class EspClawHttpClient {
  final String ip;

  EspClawHttpClient(this.ip);

  Uri uri(String path) {
    return Uri.parse('http://$ip$path');
  }

  Future<http.Response> get(String path) {
    return http.get(uri(path));
  }

  Future<http.Response> post(
    String path,
    Map<String, dynamic> body,
  ) {
    return http.post(
      uri(path),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String path) {
    return http.delete(uri(path));
  }
}
```

---

# 31. Connection Manager

Create a single connection manager.

```text
ConnectionManager

selectedDevice
       │
       ▼
192.168.43.120
       │
       ├── REST API
       ├── WebSocket
       └── MCP
```

This avoids passing IP addresses manually throughout the app.

---

# 32. Device Health Check

After connecting:

```http
GET http://192.168.43.120/api/status
```

If successful:

```text
Device connected
```

If timeout:

```text
Device unavailable
```

If connection fails:

```text
ESP-Claw is no longer reachable.

[Retry] [Back]
```

---

# 33. Automatic Reconnection

Because the phone hotspot can change network state:

```text
Hotspot OFF
     ↓
ESP disconnected
     ↓
Hotspot ON
     ↓
ESP reconnects
     ↓
IP may change
     ↓
Flutter discovers again
```

Do not permanently assume the ESP32 IP.

Rediscover the device when:

- Wi-Fi changes
- hotspot restarts
- connection times out
- app returns from background
- device becomes unreachable

---

# 34. Multiple ESP-Claw Devices

Support multiple ESP32 devices:

```text
Devices

ESP-Claw #1
192.168.43.120
● Online

ESP-Claw #2
192.168.43.121
● Online

ESP-Claw #3
192.168.43.122
● Offline
```

Selecting one device changes the active API target.

---

# 35. No Backend Requirement

The complete local architecture is:

```text
                INTERNET
                   X
                   │
             Not required
                   │

          ┌────────────────┐
          │ Android Phone  │
          │                │
          │ Mobile Hotspot │
          │                │
          │ Flutter App    │
          └───────┬────────┘
                  │
             Local Wi-Fi
                  │
                  ▼
          ┌────────────────┐
          │ ESP32-S3       │
          │ ESP-Claw       │
          └────────────────┘
```

No:

```text
Node.js
Express
Firebase
Firestore
Render
AWS
Telegram
```

is required for Flutter ↔ ESP-Claw local communication.

---

# 36. Important Exception: LLM Internet Access

"No backend" does **not** necessarily mean "no Internet."

If ESP-Claw is configured to use:

```text
OpenAI
Claude
DeepSeek
Qwen cloud
custom LLM API
```

then the ESP32 still needs Internet access to reach that LLM provider.

Your phone can provide both:

```text
Phone hotspot
      │
      ├── Local connection → ESP32
      │
      └── Mobile Internet → ESP32 → LLM API
```

So:

### Local communication

```text
Flutter ↔ ESP32
```

works without Internet.

### Cloud LLM

```text
ESP32 → Internet → LLM provider
```

requires Internet.

---

# 37. Security Consideration

The current ESP-Claw HTTP control plane has been reported as unauthenticated on the LAN.

The documented exposed endpoints include:

```text
/api/config
/api/restart
/api/files
/api/files/upload
/api/files/mkdir
/api/capabilities
/api/lua-modules
/api/status
/api/wechat/login/*
/api/webim/*
/ws/webim
```

The same report states that file APIs can modify/delete on-device content and that the MCP listener is also unauthenticated. [2]

Therefore:

**Do not use this architecture on an untrusted public Wi-Fi network.**

For your phone hotspot + your own ESP32, the local-network model is much more controlled, but still treat the ESP32 APIs as privileged.

---

# 38. Implementation Phases

## Phase 1 — ESP Discovery

Implement:

- Hotspot/network detection
- mDNS discovery
- ESP-Claw device cards
- IP resolution
- Connection test

Deliverable:

```text
Flutter → discovers ESP32 → displays IP → Connect
```

## Phase 2 — Device Dashboard

Implement:

- `/api/status`
- `/api/capabilities`
- connection indicator
- device information

## Phase 3 — Chat

Implement:

- WebSocket `/ws/webim`
- connection
- send message
- receive message
- reconnect
- message history UI

## Phase 4 — Configuration

Implement:

- `/api/config`
- LLM configuration
- enabled capability groups

## Phase 5 — Files

Implement:

- `/api/files`
- upload
- download/read
- delete
- mkdir

## Phase 6 — Lua

Implement:

- `/api/lua-modules`
- scripts UI
- script execution according to the firmware-supported interface

## Phase 7 — Advanced Features

Add:

- Skills
- Memory
- Scheduler
- Router
- MCP
- Web Search
- HTTP request capabilities

## Phase 8 — Polish

Add:

- automatic reconnect
- device persistence
- dark UI
- error handling
- loading states
- logs
- permission handling
- offline state
- multiple device support

---

# 39. Final Recommended UX

```text
                APP START
                    │
                    ▼
          Check Hotspot/Wi-Fi
                    │
                    ▼
            Discover ESP-Claw
                    │
                    ▼
        ┌─────────────────────┐
        │ ESP32-S3             │
        │ 192.168.43.120       │
        │ ● Online             │
        └──────────┬──────────┘
                   │
                Connect
                   │
                   ▼
             DASHBOARD
                   │
       ┌───────────┼───────────┐
       ▼           ▼           ▼
     CHAT       STATUS     CAPABILITIES
       │
       ├── Web Chat
       │
       ├── Agent
       │
       └── LLM

       ▼
     TOOLS
       ├── Lua
       ├── Files
       ├── Skills
       ├── Memory
       ├── Scheduler
       ├── MCP
       ├── Web Search
       └── HTTP
```

---

# 40. Critical Development Rule

Build the Flutter app against **capability discovery and the exact firmware protocol**, not against assumptions.

Use:

```http
GET /api/capabilities
GET /api/status
GET /api/config
GET /api/lua-modules
```

for the currently documented HTTP control plane.

For chat, inspect the exact `/api/webim/*` and `/ws/webim` protocol implemented by the firmware.

For MCP, use the MCP protocol rather than treating `/mcp_server` as an ordinary JSON REST API.

This will make the app much more compatible with future ESP-Claw versions.

---

## References

[1] ESP-Claw official repository: https://github.com/espressif/esp-claw

[2] ESP-Claw issue documenting the current HTTP control plane, Web Chat endpoints, and MCP listener: https://github.com/espressif/esp-claw/issues/70

[3] ESP-Claw capability registry: https://github.com/espressif/esp-claw/blob/master/components/common/app_claw/app_capabilities.c

[4] ESP-Claw Lua module documentation: https://github.com/espressif/esp-claw/blob/master/docs/src/content/docs/en/reference-cap/lua-modules.mdx

[5] ESP-Claw changelog: https://github.com/espressif/esp-claw/blob/master/CHANGELOG.md

[6] ESP-Claw MCP server application: https://github.com/espressif/esp-claw/blob/master/application/mcp_server_point/README.md

[7] ESP-Claw MCP client capability: https://github.com/espressif/esp-claw/blob/master/components/claw_capabilities/cap_mcp_client/include/cap_mcp_client.h

[8] ESP-Claw architecture / event routing: https://github.com/espressif/esp-claw/blob/master/AGENTS.md

[9] ESP-Claw IM platform documentation: https://github.com/espressif/esp-claw/blob/master/docs/src/content/docs/en/reference-cap/cap-im-platform.mdx
