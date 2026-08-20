# Vertex-Agent Setup and Run Guide

This guide explains how to compile the Vertex-Agent project using Docker and how to flash the resulting binaries to your ESP32 device using the local web flasher.

## 1. Build the Firmware (using Docker)

Because compiling ESP-IDF projects requires specific C/C++ toolchains and Node.js for the web interface, a Docker environment is provided to guarantee everything works smoothly.

### Start the Build Environment
Open a terminal in the root of this repository and launch the container:
```bash
docker-compose run --rm builder
```
*(This drops you into an interactive `bash` shell with all ESP-IDF and Node.js tools already loaded!)*

### Configure Your Board
Once inside the container, navigate to the main edge agent directory:
```bash
cd application/edge_agent
```
Configure the project for your specific hardware board. Available boards are located in the `./boards` directory. 
For example, for an ESP32-S3 DevKit, run:
```bash
idf.py bmgr -c ./boards -b esp32_S3_DevKitC_1
```

### Compile
Start the build process. This will compile the Node.js SolidJS web interface and build the C/C++ firmware binaries:
```bash
idf.py build
```
Once this completes, three important `.bin` files will be generated in `application/edge_agent/build/`:
- Bootloader: `build/bootloader/bootloader.bin`
- Partition Table: `build/partition_table/partition-table.bin`
- Firmware App: `build/vertex-agent.bin`

You can now type `exit` to leave the Docker container.

---

## 2. Flash the Device (via Web Browser)

Since passing USB devices into Docker can be tricky (especially on macOS and Windows), we provide a local Web Portal that allows you to flash your device directly from Chrome or Edge using Web Serial.

### Start the Local Flasher Server
Open a terminal on your host machine (not in Docker) and run:
```bash
cd tools/local_web_flasher
./serve.py
```
*(This script will automatically open your default browser to `http://localhost:8080`)*

### Flash the Board
1. Plug your ESP32 into your computer via USB.
2. In the web portal, select the three `.bin` files you compiled earlier.
3. Click **"Connect and Flash"**.
4. A browser popup will ask you to select your USB Serial Port (e.g., `usbserial-...` or `ttyACM0`). Select it and click Connect.
5. The portal will flash the device and automatically reboot it.

Enjoy your Vertex-Agent!
