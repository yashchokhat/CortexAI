import asyncio
import websockets
import json

async def listen():
    uri = "ws://192.168.1.6/ws/webim"
    print(f"Connecting to {uri}...")
    try:
        async with websockets.connect(uri) as websocket:
            print("Connected! Waiting for messages...")
            while True:
                message = await websocket.recv()
                print(f"Received: {message}")
    except Exception as e:
        print(f"Error: {e}")

asyncio.run(listen())
