#!/bin/sh
# PipeWire monitor - restarts audio stack if it dies
# Uses XDG autostart for session integration

stop_audio() {
    pkill -9 -x wireplumber 2>/dev/null
    pkill -9 -x pipewire 2>/dev/null
    sleep 2
    # Clean stale sockets after killing processes
    rm -f "$XDG_RUNTIME_DIR"/pipewire-0* 2>/dev/null
    rm -f "$XDG_RUNTIME_DIR"/pulse/native "$XDG_RUNTIME_DIR"/pulse/pid 2>/dev/null
}

start_audio() {
    pgrep -x pipewire >/dev/null || { pipewire & sleep 2; }
    pgrep -x pipewire >/dev/null || return 1
    pgrep -f "pipewire-pulse.conf" >/dev/null || { pipewire -c pipewire-pulse.conf & sleep 2; }
    pgrep -x wireplumber >/dev/null || { wireplumber & }
}

# Wait for session to settle on login
sleep 5

while true; do
    if ! pgrep -x pipewire >/dev/null; then
        logger "audio-monitor: restarting PipeWire"
        stop_audio
        start_audio
        sleep 5
    fi
    sleep 5
done
