####
####  server-setup-1.sh
####

# Run while connected to the internet.

###
### Download and install the RaspiOS image
###

cd /
sudo apt install unzip kpartx dnsmasq nfs-kernel-server -y
sudo mkdir -p /nfs/raspi1
sudo wget https://downloads.raspberrypi.org/raspios_armhf/images/raspios_armhf-2021-01-12/2021-01-11-raspios-buster-armhf.zip
unzip 2021-01-11-raspios-buster-armhf.zip
sudo kpartx -a -v 2021-01-11-raspios-buster-armhf.img
mkdir rootmnt
mkdir bootmnt
sudo mount /dev/mapper/loop0p2 rootmnt/
sudo mount /dev/mapper/loop0p1 bootmnt/
sudo cp -av rootmnt/* /nfs/raspi1/
sudo cp -av bootmnt/* /nfs/raspi1/boot/


###
### Replace some boot files with updated versions
###

cd /nfs/raspi1/boot
sudo rm start4.elf
sudo rm fixup4.dat
sudo wget https://github.com/Hexxeh/rpi-firmware/raw/master/start4.elf
sudo wget https://github.com/Hexxeh/rpi-firmware/raw/master/fixup4.dat


echo "Done!"
