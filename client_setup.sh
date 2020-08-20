#!/bin/sh
# client_setup.sh
# Author: Tianyi Liu
# Email : tianyi.liu@utsa.edu

echo "Downloading Benchmarking Platform: benchvnc ..."
git clone https://github.com/cloud-graphics-rendering/benchvnc.git

echo "setup and build benchvnc"
cd ./benchvnc
./setup.sh
./build64.sh
cd ../

echo "----------------Finished--------------"
echo "NOW,  you can run games remotely using ./start_game.sh in each game folder after connecting to TurboVNC server"
echo "Check TurboVNC:"
echo "      (client)$ ls /opt"
echo ""
echo "Connect to TurboVNC server:"
echo "      (client)$ /opt/TurboVNC/bin/vncviewer serverip:5901"

