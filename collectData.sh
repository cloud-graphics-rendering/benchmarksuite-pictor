#!/bin/bash
# Author: Tianyi Liu
# Email: liuty10@gmail.com

usage(){
     echo "Usage:"
     echo "*******************************************************************"
     echo "./collectData.sh GameName RecordFlag RunTime(s) BindCPU AutoOrHuman MultiMode"
     echo "	1) GameNames  : supertuxkart-1, supertuxkart, 0ad, redeclipse, dota2, inmindvr, imhotepvr"
     echo "	2) RecordFlag : 0 -- do not record metrics on server."
     echo "			1 -- record"
     echo "	3) RunTime(s) : How long to run the benchmark(seconds). Typically, stk, 0ad, dota2, imhotepvr: 900; redclipse: 600; inmindvr: 240"
     echo "	4) BindCPU    : 0 -- donot bind python thread to specific cpu core"
     echo "			1 -- bind"
     echo "	5) AutoOrHuman: 0 -- AI Bots runs benchmark."
     echo "			1 -- Human runs benchmark"
     echo "	6) MultiMode  : MultiMode means running multiple instances or not."
     echo "                        0 -- Single Instance."
     echo "                        1 -- run 1 game"
     echo "                        2 -- run 2 games..."
     echo "                        3 -- run 3 games..."
     echo "                        4 -- run 4 games..."
     echo "e.g: ./collectData.sh supertuxkart 1 100 0 0 1"
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
## -o:
## 	T time
## 	D date
## -d:
## 	seconds for interval
## -c:
## 	how many items to record
## -f:
## 	dump to which file
##	nvidia-smi dmon -s puctm -o T -d 1
##	nvidia-smi dmon -s puct -o T -d 2 -c 200 -f ./gpu.log
if [ $# -ne 6 ]; then
    usage
fi
APP_NAME=$1
RecordFlag=$2
RUNNING_TIME=$3
BIND_CPU=$4
HUMAN=$5
MULTIPLE_MODE=$6
################# Script starts from here ################
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

if [ $RecordFlag -eq 1 ] ; then
    rm $RESULT_DIR/*
fi

COUNT=$RUNNING_TIME
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
echo "vglrun ./start_game_real.sh --screensize=1920x1080" > ./start_game_1.sh

if [ $RecordFlag -eq 1 ] ; then
    if [ $APP_NAME = "supertuxkart-1" ] ; then
        sh ./start_game_1.sh 2>$RESULT_DIR/${APP_NAME}_fps.log &
    else
        taskset 0xe0 ./start_game.sh 2>$RESULT_DIR/${APP_NAME}_fps.log &
    fi
else
    if [ $APP_NAME = "supertuxkart-1" ] ; then
        sh ./start_game_1.sh &
    else
        taskset 0xe0 ./start_game.sh &
    fi
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
if [ $RecordFlag -eq 1 ] ; then
     cp $RESULT_DIR/game.pid $RESULT_DIR/game.keypid
     sleep 5
fi

if [ $RecordFlag -eq 1 ] ; then
    nvidia-smi dmon -s puct -o T -d 1 -c $COUNT -f $RESULT_DIR/gpu_utilization.log &
fi

networkcards=`ifconfig | grep -P '^[^\s]+\s+[A-Z]' | awk '{print $1}'`
echo $networkcards > $RESULT_DIR/networkcards_name.log
num=$COUNT

if [ $MULTIPLE_MODE -eq 0 -o $MULTIPLE_MODE -eq 1 ] ; then
    echo -en `ps -C Xvnc -o pid=` > ./Xvnc.pid
    GamePID=`echo $gamepids | awk '{$1=$1};1'`
    XvncPID=`tail -1 ./Xvnc.pid | awk '{$1=$1};1'`
    while [ $num -gt 0 ]; do
        echo "single Count: $num"
        if [ $RecordFlag -eq 1 ] ; then
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
    cp /tmp/vgl/$XvncPID $RESULT_DIR/vnc_fps.log
else
    GamePID=`cat $RESULT_DIR/game.keypid | awk '{$1=$1};1'`
    while [ $num -gt 0 ]; do
        echo "multiple Count: $num"
        if [ $RecordFlag -eq 1 ] ; then
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
    if [ $RecordFlag -eq 1 ] ; then
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

