#!/bin/bash

# see https://en.wikipedia.org/wiki/Xvfb#Remote_control_over_SSH
: "${DISPLAY:=":0"}"
export DISPLAY;
VNC_PORT=5900
NOVNC_PORT=6080

tmux new-session -d -s xvfb "Xvfb -screen $DISPLAY ${CUSTOM_XVFB_WxHxD:=1920x1080x16} -ac -pn -noreset";
sleep 2;
tmux new-session -d -s x11vnc "x11vnc -localhost -shared -display $DISPLAY -forever -rfbport ${VNC_PORT} -bg -o /tmp/x11vnc-${DISPLAY}.log";
sleep 2;
tmux new-session -d -s novnc "cd /opt/novnc/utils && ./novnc_proxy --vnc localhost:${VNC_PORT} --listen ${NOVNC_PORT}";
sleep 5;
tmux new-session -d -s dbuslog '{ cd && chmod +x .xinitrc && exec $PWD/.xinitrc 2>&1; } > /tmp/dbus.log 2>&1';