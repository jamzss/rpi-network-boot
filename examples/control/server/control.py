"""
Simple test of the client webserver, attempting to set the state of led0 on the client.
"""

import requests

r = requests.get("http://192.168.10.28:8000/led0/on")
print(r.text)