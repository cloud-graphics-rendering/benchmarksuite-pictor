#!/bin/bash
GEOMETRY=$(cat ~/.vnc/geometry.cfg)
[ -z $GEOMETRY ] && GEOMETRY=1920x1080

#vglrun ./start_game.sh --race-now --mode=0 --track=antediluvian_abyss --demo-laps=99 --demo-karts=5 --kart=sara_the_racer --numkarts=100 --screensize=1280x960
#vglrun ./start_game.sh --race-now --mode=0 --track=cornfield_crossing --demo-laps=99 --demo-karts=5 --kart=sara_the_racer --numkarts=100 --screensize=1280x960
#vglrun ./start_game.sh --race-now --mode=0 --track=abyss --demo-laps=99 --demo-karts=5 --kart=sara_the_racer --numkarts=100 --screensize=1280x960
#vglrun ./start_game.sh --race-now --mode=0 --track=abyss --demo-laps=99 --demo-karts=5 --kart=sara_the_racer --numkarts=100 --screensize=1920x1080
#vglrun ./start_game_real.sh --race-now --mode=0 --track=abyss --demo-laps=99 --demo-karts=5 --kart=sara_the_racer --numkarts=100 --screensize=1280x720
vglrun ./start_game_real.sh --race-now --mode=0 --track=abyss --demo-laps=99 --demo-karts=5 --kart=sara_the_racer --numkarts=100 --screensize=$GEOMETRY --fullscreen
