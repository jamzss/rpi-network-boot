# Webserver example

An simple example of a Flask webserver enabling the control of clients from the server.


### Installation
##### Client
```
sudo pip3 install flask selenium
sudo apt install chromium-chromedriver
sudo wget https://github.com/jamzss/rpi-network-boot/raw/main/examples/control/client/ws.py
```

To run the client webserver on startup, append the following line to `/etc/rc.local` on the client. The filepath will depend on where you download the file to:
```
python3 /home/piremote/ws.py &
```


##### Server
```
sudo wget https://github.com/jamzss/rpi-network-boot/raw/main/examples/control/server/control.py
```
