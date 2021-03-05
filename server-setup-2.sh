####
####  server-setup-2.sh
####

# Run while connected to your isolated network and after setting your country code in raspi-config

# Here you will need to change values to
# your specific setup.


# The last 8 characters of your client pi serial number
serial="c94401e1"

# The SSID of your wireless network
network_ssid="BTHub5-7Q5F-5Ghz"

# The password of your wireless network
network_psk="ecc92cd96a"

# The address of the router on your wireless network
router_address="192.168.1.254"


###
### Set up TFTP
###

cd /
sudo mkdir -p /tftpboot/$serial
echo "/nfs/raspi1/boot /tftpboot/$serial none defaults,bind 0 0" | sudo tee -a /etc/fstab
sudo mount /tftpboot/$serial
sudo chmod 777 /tftpboot
sudo touch /nfs/raspi1/boot/ssh
sudo sed -i /UUID/d /nfs/raspi1/etc/fstab
echo "console=serial0,115200 console=tty root=/dev/nfs nfsroot=192.168.10.1:/nfs/raspi1,vers=3 rw ip=dhcp rootwait elevator=deadline" | sudo tee /nfs/raspi1/boot/cmdline.txt
echo "/nfs/raspi1 *(rw,sync,no_subtree_check,no_root_squash)" | sudo tee -a /etc/exports


###
### Initial dnsmasq and wpa_supplicant configuration
###

echo 'log-dhcp' | sudo tee -a /etc/dnsmasq.conf
echo 'enable-tftp' | sudo tee -a /etc/dnsmasq.conf
echo 'tftp-root=/tftpboot' | sudo tee -a /etc/dnsmasq.conf
echo 'pxe-service=0,"Raspberry Pi Boot"' | sudo tee -a /etc/dnsmasq.conf
echo "network={" | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf
echo ssid=\"$network_ssid\" | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf
echo psk=\"$network_psk\" | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf
echo "}" | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf


###
### Set up iptables and have them reload on boot
###   (by default, they are not persistent)
###

sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
sudo iptables -A FORWARD -i wlan0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i eth0 -o wlan0 -j ACCEPT
sudo sh -c "sudo iptables-save > /etc/iptables.v4"
sudo sed -i "$ d" /etc/rc.local
echo 'sudo sh -c "iptables-restore < /etc/iptables.v4"' | sudo tee -a /etc/rc.local
echo 'sudo route add -net default gw 192.168.10.1 netmask 0.0.0.0 dev eth0' | sudo tee -a /etc/rc.local
echo "1" | sudo tee /proc/sys/net/ipv4/ip_forward
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf


###
### Final dnsmasq configuration
###

echo "interface=eth0" | sudo tee -a /etc/dnsmasq.conf
echo "bind-interfaces" | sudo tee -a /etc/dnsmasq.conf
echo "server=8.8.8.8" | sudo tee -a /etc/dnsmasq.conf
echo "domain-needed" | sudo tee -a /etc/dnsmasq.conf
echo "bogus-priv" | sudo tee -a /etc/dnsmasq.conf
echo "dhcp-range=192.168.10.20,192.168.10.30,12h" | sudo tee -a /etc/dnsmasq.conf


###
### Set up server ethernet interface
###

echo "interface eth0" | sudo tee -a /etc/dhcpcd.conf
echo "static ip_address=192.168.10.1" | sudo tee -a /etc/dhcpcd.conf
sudo sed -i "$ d" /etc/resolv.conf
echo "nameserver $router_address" | sudo tee -a /etc/resolv.conf


###
### Final wireless configuration
###

sudo wpa_cli -i wlan0 reconfigure


echo "Done!"
