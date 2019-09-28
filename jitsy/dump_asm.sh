#!/bin/bash

gdb -batch "$1" -ex 'disassemble var_0' \
    | head --lines=-1 \
    | tail --lines=+2 \
    | cut --fields="2"
