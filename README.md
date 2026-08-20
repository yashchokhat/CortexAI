# CortexAI

Welcome to the **CortexAI** project workspace! 

This repository serves as the central hub for our Edge AI and IoT agent development, containing the tools and sub-projects required to run intelligent agents locally on microcontrollers.

## Structure

- **[`vertex-agent/`](./vertex-agent/)**: The primary edge AI agent framework for IoT devices. This project allows you to run AI agents directly on ESP32-series chips (such as ESP32-S3, ESP32-P4), turning them into active decision-making centers capable of Chat Coding, dynamic tool invocation, and offline edge computing.

## Getting Started

To get started with the IoT edge agent:

1. Navigate into the `vertex-agent/` directory:
   ```bash
   cd vertex-agent
   ```
2. Follow the detailed setup instructions in **[`vertex-agent/setup.md`](./vertex-agent/setup.md)** to:
   - Compile the firmware using our pre-configured Docker container.
   - Run the local Web Portal to flash your custom binaries directly from your browser via Web Serial.

## Tools & Utilities

- **Local Web Flasher**: A browser-based Web Serial flashing tool is located at `vertex-agent/tools/local_web_flasher`. It allows you to quickly deploy your locally built `.bin` firmware files straight to your hardware without needing `esptool.py` or local Python dependencies configured.

---
*Created and maintained by yash.*
