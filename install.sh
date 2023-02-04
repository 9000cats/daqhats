#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root, i.e 'sudo ./install.sh'" 1>&2
   exit 1
fi

# Build / install the C library and headers
echo "Building and installing library"
echo
make -C lib all
make -C lib install
make -C lib clean

echo

# Build / install tools
echo "Building and installing tools"
echo
make -C tools all
make -C tools install
make -C tools clean

echo

# Read HAT EEPROMs to /etc/mcc/hats
echo "Reading DAQ HAT EEPROMs"
echo
daqhats_read_eeproms

echo

echo "Installing library for Python 3"
dpkg-query -l python3-pip &> /dev/null
if [ "$?" != "0" ]; then
   apt-get -qy install python3-pip
fi
pip3 install . --upgrade


echo

# Turn SPI on (needed for some MCC 118s that had incorrectly programmed EEPROMs)
if [ $(raspi-config nonint get_spi) -eq 1 ]; then
   raspi-config nonint do_spi 0
fi

echo "Install complete"
