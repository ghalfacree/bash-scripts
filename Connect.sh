#!/bin/bash
killall synergyc
synergyc -n righter 192.168.0.11
ssh -X blacklaw@192.168.0.11 gnome-terminal --full-screen --window-with-profile=Monochrome --hide-menubar
