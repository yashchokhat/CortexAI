#!/usr/bin/env python3
import http.server
import socketserver
import webbrowser
import os

DIRECTORY = os.path.dirname(os.path.abspath(__file__))
os.chdir(DIRECTORY)

Handler = http.server.SimpleHTTPRequestHandler
# Use port 0 to automatically allocate a free port
with socketserver.TCPServer(("", 0), Handler) as httpd:
    PORT = httpd.server_address[1]
    url = f"http://localhost:{PORT}"
    print(f"Serving local web flasher at {url}")
    print("Press Ctrl+C to stop.")
    
    # Open the default web browser automatically
    webbrowser.open(url)
    
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down server.")
