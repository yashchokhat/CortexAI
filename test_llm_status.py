import asyncio
import websockets
import json
import requests

async def main():
    uri = "ws://192.168.1.6/ws/webim"
    try:
        async with websockets.connect(uri) as websocket:
            print("Connected. Sending /help")
            res = requests.post(
                "http://192.168.1.6/api/webim/send", 
                json={"chat_id": "default", "text": "/help"}
            )
            print("POST response:", res.json())
            
            while True:
                msg = await asyncio.wait_for(websocket.recv(), timeout=5.0)
                print(f"Received: {msg}")
    except Exception as e:
        print(f"Error: {e}")

asyncio.run(main())
