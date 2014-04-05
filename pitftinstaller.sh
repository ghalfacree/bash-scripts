#!/bin/bash
# Script to perform the installation of the PiTFT software.
# Written by Gareth Halfacree <freelance@halfacree.co.uk>

if [[ $UID -ne 0 ]]; then
  echo "This script must be run as root or via sudo."
  exit 1
fi

if [[ -e /root/.pitft ]]; then
  echo "PiTFT already installed."
  exit 0
else
  echo Installing PiTFT software...
  apt-get update && apt-get install -f -y && apt-get upgrade -y
  mkdir /tmp/pitft
  cd /tmp/pitft
  wget http://adafruit-download.s3.amazonaws.com/libraspberrypi-bin-adafruit.deb
  wget http://adafruit-download.s3.amazonaws.com/libraspberrypi-dev-adafruit.deb
  wget http://adafruit-download.s3.amazonaws.com/libraspberrypi-doc-adafruit.deb
  wget http://adafruit-download.s3.amazonaws.com/libraspberrypi0-adafruit.deb
  wget http://adafruit-download.s3.amazonaws.com/raspberrypi-bootloader-adafruit-20140227-1.deb
  wget http://adafruit-download.s3.amazonaws.com/xinput-calibrator_0.7.5-1_armhf.deb
  sudo dpkg -i -B *.deb
  apt-get install evtest tslib libts-bin -y
  echo "spi-bcm2708" >> /etc/modules
  echo "fbtft_device" >> /etc/modules
  echo "options fbtft_device name=adafruitts rotate=90 frequency=32000000" > /etc/modprobe.d/adafruit.conf
  mkdir /etc/X11/xorg.conf.d
  echo "Section \"InputClass\"" >> /etc/X11/xorg.conf.d/99-calibration.confapt-g
  echo -e "\tIdentifier\t\"calibration\"" >> /etc/X11/xorg.conf.d/99-calibration.conf
  echo -e "\tMatchProduct\t\"smpe-ts\"" >> /etc/X11/xorg.conf.d/99-calibration.conf
  echo -e "\tOption\t\"Calibration\"\t\"3800 200 200 3800\"" >> /etc/X110/xorg.conf.d/99-calibration.conf
  echo -e "\tOption\t\"SwapAxes\"\t\"1\"" >> /etc/X11/xorg.conf.d/99-calibration.conf
  echo "EndSection" >> /etc/X11/xorg.conf.d/99-calibration.conf
  echo "export FRAMEBUFFER=/dev/fb1" >> /home/pi/.profile
  echo "SUBSYSTEM==\"input\", ATTRS{name}==\"stmpe-ts\", ENV{DEVNAME}==\"*event*\", SYMLINK+=\"input/touchscreen\"" >> /etc/udev/rules.d/95-stmpe.rules
  rmmod stmpe_ts
  modprobe stmpe_ts
  cmdline=$(cat /boot/cmdline.txt)
  echo "$cmdline fbcon=map:10 fbcon=font:VGA8x8" > /boot/cmdline.txt
  apt-get install -f -y
  touch /root/.pitft
  clear && echo System will now shut down. Disconnect USB cable and install PiTFT.
  shutdown -h now
  exit 0
fi
