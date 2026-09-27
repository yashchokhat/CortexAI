import asyncio
import websockets
import json
import requests
import time

async def main():
    uri = "ws://192.168.1.6/ws/webim"
    print(f"Connecting to {uri}...")
    try:
        async with websockets.connect(uri) as websocket:
            print("Connected to WS! Sending HTTP POST...")
            
            # Send HTTP POST
            res = requests.post(
                "http://192.168.1.6/api/webim/send", 
                json={"chat_id": "default", "text": "Are you alive?"}
            )
            print("POST response:", res.json())
            
            # Listen on WS
            print("Waiting for WS messages...")
            while True:
                msg = await asyncio.wait_for(websocket.recv(), timeout=20.0)
                print(f"Received from WS: {msg}")
    except Exception as e:
        print(f"Error: {e}")

asyncio.run(main())
