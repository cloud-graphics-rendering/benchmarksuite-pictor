#!/bin/bash
#export LD_PRELOAD=libdlfaker.so:/media/lty/newspace/BenchmarkFrameWork/Platforms-working/BenchmarkSuite-Server/libvglfaker.so
#./imhotepvr-linux.x86_64 & echo $! > ./game.pid
vglrun ./imhotepvr-linux.x86_64 & echo $! > ./game.pid
