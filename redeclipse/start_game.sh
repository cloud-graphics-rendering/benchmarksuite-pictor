#!/bin/bash
WIDTH=$(cat ~/.vnc/geometry.cfg | cut -dx -f1)
HEIGHT=$(cat ~/.vnc/geometry.cfg | cut -dx -f2)
[ -z $WIDTH ] && WIDTH=1920
[ -z $HEIGHT ] && HEIGHT=1080

[ -e ~/.redeclipse ] || mkdir ~/.redeclipse
echo "fullscreen 1" > ~/.redeclipse/init.cfg
echo "fullscreendesktop 0" >> ~/.redeclipse/init.cfg
echo "scr_w $WIDTH" >> ~/.redeclipse/init.cfg
echo "scr_h $HEIGHT" >> ~/.redeclipse/init.cfg
echo "depthbits 0" >> ~/.redeclipse/init.cfg
echo "fsaa 16" >> ~/.redeclipse/init.cfg
echo "soundnono 0" >> ~/.redeclipse/init.cfg
echo "soundmixchans 32" >> ~/.redeclipse/init.cfg
echo "soundbuflen 4096" >> ~/.redeclipse/init.cfg
echo "soundfreq 44100" >> ~/.redeclipse/init.cfg
echo "verbose 0" >> ~/.redeclipse/init.cfg
echo "noconfigfile 0" >> ~/.redeclipse/init.cfg

vglrun ./redeclipse.sh
