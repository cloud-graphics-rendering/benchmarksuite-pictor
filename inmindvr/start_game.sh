#!/bin/bash
#export LD_PRELOAD=libdlfaker.so:/media/lty/newspace/BenchmarkFrameWork/Platforms-working/BenchmarkSuite-Server/libvglfaker.so
#./InMind.x86_64 & echo $! > ./game.pid
vglrun ./InMind.x86_64 & echo $! > ./game.pid
