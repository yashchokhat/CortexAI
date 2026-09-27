import asyncio
import websockets
import json
import requests
import time

async def main():
    uri = "ws://192.168.1.6/ws/webim"
    try:
        async with websockets.connect(uri) as websocket:
            print("Connected to WS! Sending HTTP POST...")
            
            res = requests.post(
                "http://192.168.1.6/api/webim/send", 
                json={"chat_id": "default", "text": "Hi, reply quickly!"},
                headers={"Content-Type": "application/json"}
            )
            print("POST response:", res.json())
            
            print("Waiting for WS messages...")
            while True:
                msg = await asyncio.wait_for(websocket.recv(), timeout=60.0)
                print(f"Received from WS: {msg}")
                try:
                    data = json.loads(msg)
                    if data.get("final"):
                        print("Final message received, stopping.")
                        break
                except:
                    pass
    except Exception as e:
        print(f"Error/Timeout: {e}")

asyncio.run(main())
