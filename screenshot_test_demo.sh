#!/bin/bash
set -e

DISPLAY_NUM=99
SCREEN_SIZE="400x300x24"
SCREENSHOT="./screenshot.png"

cleanup() {
    echo "Cleaning up..."
    [ -n "$XEYES_PID" ] && kill "$XEYES_PID" 2>/dev/null || true
    [ -n "$XVFB_PID" ] && kill "$XVFB_PID" 2>/dev/null || true
}
trap cleanup EXIT

echo "Starting Xvfb on display :$DISPLAY_NUM..."
Xvfb :$DISPLAY_NUM -screen 0 $SCREEN_SIZE &
XVFB_PID=$!
export DISPLAY=:$DISPLAY_NUM
sleep 1

echo "Launching xeyes..."
xeyes -geometry 200x200+100+50 &
XEYES_PID=$!
sleep 1  # wait for window to render

echo "Capturing screenshot..."
import -window root "$SCREENSHOT"
echo "Screenshot saved to $SCREENSHOT"
