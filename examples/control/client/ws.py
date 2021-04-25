"""
Run a Flask webserver allowing communication with the server Pi
"""

import os
import sys

# Dirty fix for path issues
sys.path.append("/home/pi/.local/lib/python3.7/site-packages")

from flask import Flask, request
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from markupsafe import escape


app = Flask(__name__)

# Simple test route
@app.route("/test")
def route_test():
    return "Test received!"


# Launch the chromium browser and open the BBC website as a test.
@app.route("/launchbrowser")
def route_launchbrowser():
    options = webdriver.ChromeOptions()
    options.add_argument("--no-sandbox")
    options.add_argument("--start-maximized") # Can be omitted
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--headless")
    options.use_experimental_option("useAutomationExtension", false)
    options.use_experimental_option("detatch", True) # Keep browser open even after route returns
    
    chrome = webdriver.Chrome("/usr/bin/chromedriver")
    chrome.get("https://news.bbc.co.uk")
    chome.switch_to_window(chrome.current_window_handle)
    chrome.fullscreen_window() # Sometimes the options argument won't work properly, this is more reliable
    
    return "OK"


# Turn led1 on
@app.route("/led1/on")
def route_led1_on():
    try:
        os.system('sudo sh -c "echo 1 >/sys/class/leds/led1/brightness"')
        return "OK"
    except:
        return "ERROR"


# Turn led1 off
@app.route("/led1/off")
def route_led1_off():
    try:
        os.system('sudo sh -c "echo 0 >/sys/class/leds/led1/brightness"')
        return "OK"
    except:
        return "ERROR"


# Return the current CPU temperature
@app.route("/cpu_temp")
def route_cpu_temp():
    try:
        temp = str(os.popen("vcgencmd measure_temp").read()).split('=')[1]
        return temp
    except:
        return "ERROR"


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=8000) # Manual host set so it's not run on localhost