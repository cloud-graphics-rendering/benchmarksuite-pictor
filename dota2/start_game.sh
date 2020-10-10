#!/bin/bash
WIDTH=$(cat ~/.vnc/geometry.cfg | cut -dx -f1)
HEIGHT=$(cat ~/.vnc/geometry.cfg | cut -dx -f2)
[ -z $WIDTH ] && WIDTH=1920
[ -z $HEIGHT ] && HEIGHT=1080

vglrun ./game/dota.sh -safemode -w $WIDTH -h $HEIGHT
