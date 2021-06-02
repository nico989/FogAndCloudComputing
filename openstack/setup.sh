#!/bin/sh
sudo dnf install -y python3
sudo python3 /home/centos/bot.py > logs.txt &
