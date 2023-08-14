#!/bin/sh

glmark2-es2-wayland --benchmark refract --run-forever > /dev/null &
sleep 1
for i in {1..5};
do
    XDG_RUNTIME_DIR=/run/user/1000 glmark2-es2-wayland --benchmark refract --run-forever --off-screen > /dev/null &
    sleep 1
done
