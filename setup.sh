#!/bin/sh
# Author: Tianyi Liu
# Email : tianyi.liu@utsa.edu


export CGR_BENCHMARK_PATH=`pwd`
echo "-----------Going to download D2, IM, ITP, STK, RE, 0AD ----------"

echo "Downloading D2 ..."
wget https://sourceforge.net/projects/cloud3d-bench/files/dota2.tar.bz2
tar -xf dota2.tar.bz2 &

echo "Downloading IM ..."
wget https://sourceforge.net/projects/cloud3d-bench/files/inmindvr.tar.bz2
tar -xf inmindvr.tar.bz2 &

echo "Downloading ITP ..."
wget https://sourceforge.net/projects/cloud3d-bench/files/imhotepvr.tar.bz2
tar -xf imhotepvr.tar.bz2 &

echo "Downloading STK ..."
wget https://sourceforge.net/projects/cloud3d-bench/files/supertuxkart.tar.bz2
tar -xf supertuxkart.tar.bz2 &

echo "Downloading RE ..."
wget https://sourceforge.net/projects/cloud3d-bench/files/redeclipse.tar.bz2
tar -xf redeclipse.tar.bz2 &

echo "Downloading 0AD ..."
wget https://sourceforge.net/projects/cloud3d-bench/files/0ad.tar.bz2
tar -xf 0ad.tar.bz2

echo "----------Downloading Done!!---------------"
rm ./*.tar.bz2

echo "-------------Configuration-----------------"
rm $HOME/.redeclipse -rf
cp ./redeclipse/benchconf/_.redeclipse $HOME/.redeclipse -r
sudo apt-get install libsdl2-mixer-2.0-0 libsdl2-image-2.0-0 libsdl2-2.0-0

mkdir -p $HOME/.local/share/0ad/saves && \
cp ./0ad/benchconf/* $HOME/.local/share/0ad/saves/
sudo mv ./imhotepvr/libgloox.so.17.0.0 /usr/lib/x86_64-linux-gnu/libgloox.so.17.0.0
sudo mv ./imhotepvr/libsodium.so.23.1.0 /usr/lib/x86_64-linux-gnu/libsodium.so.23.1.0
sudo ln -s /usr/lib/x86_64-linux-gnu/libgloox.so.17.0.0 /usr/lib/x86_64-linux-gnu/libgloox.so.17
sudo ln -s /usr/lib/x86_64-linux-gnu/libsodium.so.23.1.0 /usr/lib/x86_64-linux-gnu/libsodium.so.23
echo "----------Configuration Done!!--------------"

echo "ATTENTION: Since DoTA2 and Inmind VR are closed-source, you should download it from steam by yourself on Linux, and then copy to dota2 and inmindvr folders"
echo " "
echo "----------------Finished--------------"
echo "Now, you can enter each folder and run games locally using ./start_game_real.sh"
echo "OR,  you can enter each folder and run games remotely (in cloud) using ./start_game.sh with the support of BenchVNC and BenchVirtualGL"

