#!/bin/bash
# Author: Tianyi Liu
# Email: liuty10@gmail.com

usage(){
     echo "Usage:"
     echo "*******************************************************************"
     echo "./collectData.sh app_name associate_flag timeInSeconds bindorNot humanOrNot network_card package_num intervalInSeconds"
     echo "./collectData.sh supertuxkart 1 300 0 0 enp0s31f6 1000 0"
     echo "gameNames: supertuxkart, 0ad, redeclipse, dota2, inmindvr, imhotepvr, nasawebvr, javaeclipse, libreoffice"
     echo "1) app_name      : one of the game names above."
     echo "2) associate_flag: 0 -- do not record event on server(default). 
                              1 -- record events on server"
     echo "3) timeInSeconds : How long to run the benchmark in seconds(default: 60)."
     echo "4) bindorNot     : 0 -- do not bind to specific cpu(default: 0). 
                              1 -- bind python thread to perticular cpu core."
     echo "5) humanOrNot    : 0 -- auto run benchmark(default: 0). 
                              1 -- Human play games."
     echo "6) network_card  : Network card name.Eg: eth0(default: enp0s31f6)." 
     echo "7) package_num   : Number of network packages that we want to grab(default: 1000)." 
     echo "8) MultipleMode  : 0---single game; If not 0: multiple game mode. 1---run 1game, 2---run 2games, 3---run 3games, 4---run 4 games." 
     exit 0
}

################ Monitoring ###################
##*********For GPU Monitoring ****************
## -s:
## 	p: power usage(in Watts, Temprature in C)
## 	u: Utilization(SM, Memory, Encoder, Decoder in %)
## 	c: Proc and Mem Clock(in MHz)
## 	t: PCIe Rx and Tx Throughput in MB/s(Maxwell and above)
## 	m: Frame Buffer and Bar1 memory usage(in MB)
##
## -o:
## 	T time
## 	D date
##
## -d:
## 	seconds for interval
##
## -c:
## 	how many items to record
##
## -f:
## 	dump to which file
##
##	nvidia-smi dmon -s puctm -o T -d 1
##	nvidia-smi dmon -s puct -o T -d 2 -c 200 -f ./gpu.log
################# Script starts from here ################
APP_NAME="default"
associateFlag=1
RUNNING_TIME=6
CLIENT_NAME=enp0s31f6
NETWORK_PORT=5901
HOST_IP=10.100.233.104
PACKAGE_NUM=1000
AI_BOTS_DIR=$(dirname `pwd`)
BIND_CPU=0
HUMAN=0
RESULT_DIR=`pwd`/result_server_cgr_nobind/$APP_NAME
MULTIPLE_MODE=0
##########################################################

if [ $# -eq 0 ]; then
    usage
fi

case $# in
    1)
       APP_NAME=$1
       ;;
    2)
       APP_NAME=$1
       associateFlag=$2
       ;;
    3)
       APP_NAME=$1
       associateFlag=$2
       RUNNING_TIME=$3
       ;;
    4)
       APP_NAME=$1
       associateFlag=$2
       RUNNING_TIME=$3
       BIND_CPU=$4
       ;;
    5)
       APP_NAME=$1
       associateFlag=$2
       RUNNING_TIME=$3
       BIND_CPU=$4
       HUMAN=$5
       ;;
    6)
       APP_NAME=$1
       associateFlag=$2
       RUNNING_TIME=$3
       BIND_CPU=$4
       HUMAN=$5
       MULTIPLE_MODE=$6
       ;;
    7)
       APP_NAME=$1
       associateFlag=$2
       RUNNING_TIME=$3
       BIND_CPU=$4
       HUMAN=$5
       MULTIPLE_MODE=$6
       CLIENT_NAME=$7
       ;;
    8)
       APP_NAME=$1
       associateFlag=$2
       RUNNING_TIME=$3
       BIND_CPU=$4
       HUMAN=$5
       MULTIPLE_MODE=$6
       CLIENT_NAME=$7
       PACKAGE_NUM=$8
       ;;
    *)
       usage
       ;;
esac

COUNT=$RUNNING_TIME
if [ $MULTIPLE_MODE -ne 0 ] ; then
    RESULT_DIR=`pwd`/result_server_cgr_nobind_auto_multi_${MULTIPLE_MODE}/$APP_NAME
elif [ $BIND_CPU -eq 0 ] ; then
    if [ $HUMAN -eq 0 ] ; then
        RESULT_DIR=`pwd`/result_server_cgr_nobind_auto/$APP_NAME
    else
        RESULT_DIR=`pwd`/result_server_cgr_nobind_human/$APP_NAME
    fi
else
    if [ $HUMAN -eq 0 ] ; then
        RESULT_DIR=`pwd`/result_server_cgr_bind_auto/$APP_NAME
    else
        RESULT_DIR=`pwd`/result_server_cgr_bind_human/$APP_NAME
    fi
fi
[ -e `dirname $RESULT_DIR` ] || mkdir `dirname $RESULT_DIR`
[ -e $RESULT_DIR ] || mkdir $RESULT_DIR

if [ $associateFlag -eq 1 ] ; then
    rm $RESULT_DIR/*
fi

#[ -r ./$APP_NAME ] || (echo "Application name NOT correct\n" && exit 1)

echo "Running Time: $RUNNING_TIME seconds"
echo "Count: $COUNT"
echo "running.."

if [ $APP_NAME = "supertuxkart-1" ] ; then
    cd ./supertuxkart
else
    [ -r ./$APP_NAME ] || (echo "Application name NOT correct\n" && exit 1)
    cd ./$APP_NAME
fi

rm /tmp/source_engine_2808995433.lock
if [ $associateFlag -eq 1 ] ; then
    ./start_game.sh 2>$RESULT_DIR/${APP_NAME}_fps.log &
else
    ./start_game.sh &
fi

sleep 5

if [ $APP_NAME = "redeclipse" ] ; then
    ps -C redeclipse_linux -o pid= > $RESULT_DIR/game.pid
elif [ $APP_NAME = "supertuxkart" ] ; then
    ps -C supertuxkart -o pid= > $RESULT_DIR/game.pid
elif [ $APP_NAME = "supertuxkart-1" ] ; then
    ps -C supertuxkart -o pid= > $RESULT_DIR/game.pid
elif [ $APP_NAME = "0ad" ] ; then
    ps -C pyrogenesis -o pid= > $RESULT_DIR/game.pid
elif [ $APP_NAME = "dota2" ] ; then
    ps -C dota2 -o pid= > $RESULT_DIR/game.pid
elif [ $APP_NAME = "inmindvr" ] ; then
    ps -C "InMind.x86_64" -o pid= > $RESULT_DIR/game.pid
elif [ $APP_NAME = "imhotepvr" ] ; then
    ps -C "imhotepvr-linux.x86_64" -o pid= > $RESULT_DIR/game.pid
elif [ $APP_NAME = "nasawebvr" ] ; then
    ps -C firefox -o pid= > $RESULT_DIR/game.pid
else
    echo "Other Games"
fi

gamepids=`cat $RESULT_DIR/game.pid`
if [ $associateFlag -eq 1 ] ; then
     cp $RESULT_DIR/game.pid $RESULT_DIR/game.keypid
     sleep 5
fi

if [ $associateFlag -eq 1 ] ; then
    nvidia-smi dmon -s puct -o T -d 1 -c $COUNT -f $RESULT_DIR/gpu_utilization.log &
fi

networkcards=`ifconfig | grep -P '^[^\s]+\s+[A-Z]' | awk '{print $1}'`
echo $networkcards > $RESULT_DIR/networkcards_name.log
num=$COUNT

if [ $MULTIPLE_MODE -eq 0 ] ; then
    echo -en `ps -C Xvnc -o pid=` > ./Xvnc.pid
    GamePID=`echo $gamepids | awk '{$1=$1};1'`
    XvncPID=`tail -1 ./Xvnc.pid | awk '{$1=$1};1'`
    while [ $num -gt 0 ]; do
        echo "single Count: $num"
        if [ $associateFlag -eq 1 ] ; then
            cat /proc/stat >> $RESULT_DIR/proc_stat.log                      # overall CPU
            cat /proc/meminfo >> $RESULT_DIR/proc_meminfo.log                # overall Mem
            cat /proc/uptime >> $RESULT_DIR/proc_uptime.log                  # For PID CPU
            cat /proc/net/dev >> $RESULT_DIR/proc_network_card.log           # Network Card
            cat /proc/$GamePID/stat >> $RESULT_DIR/proc_Game_stat.log        # Game CPU Util
            cat /proc/$GamePID/status >> $RESULT_DIR/proc_Game_status.log    # Game Memory Util
            cat /proc/$XvncPID/stat >> $RESULT_DIR/proc_Xvnc_stat.log        # VNC server CPU Util
            cat /proc/$XvncPID/status >> $RESULT_DIR/proc_Xvnc_status.log    # VNC server Mem Util
        fi
        sleep 1
        num=`expr $num - 1`
    done
    kill $GamePID
    cp /tmp/vgl/$GamePID $RESULT_DIR/serverfps_swapbuffer_time.log
else
    GamePID=`cat $RESULT_DIR/game.keypid | awk '{$1=$1};1'`
    while [ $num -gt 0 ]; do
        echo "multiple Count: $num"
        if [ $associateFlag -eq 1 ] ; then
            cat /proc/stat >> $RESULT_DIR/proc_stat.log                      # overall CPU
            cat /proc/meminfo >> $RESULT_DIR/proc_meminfo.log                # overall Mem
            cat /proc/uptime >> $RESULT_DIR/proc_uptime.log                  # For PID CPU
            cat /proc/net/dev >> $RESULT_DIR/proc_network_card.log           # Network Card
            if [ $MULTIPLE_MODE -eq 1 ] ; then
                cat /proc/$GamePID/stat >> $RESULT_DIR/proc_Game_stat.log        # Game CPU Util
                cat /proc/$GamePID/status >> $RESULT_DIR/proc_Game_status.log    # Game Memory Util
            fi
        fi
        sleep 1
        num=`expr $num - 1`
    done
    if [ $associateFlag -eq 1 ] ; then
        gamepids=`cat $RESULT_DIR/game.pid`
        for gamepid in ${gamepids[*]}
        do
            gamepid=`echo $gamepid | awk '{$1=$1};1'`
            kill $gamepid
            cp /tmp/vgl/$gamepid $RESULT_DIR/serverfps_swapbuffer_time_${gamepid}.log
        done
        kill $GamePID
        cp /tmp/vgl/$GamePID $RESULT_DIR/serverfps_swapbuffer_time.log
    fi
fi

echo "Done"

