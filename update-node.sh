#!/bin/bash

folder=$(echo $(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) | awk -F/ '{print $NF}')
source ~/scripts/$folder/cfg
source ~/.bash_profile

sudo systemctl stop $BINARY.service

cd ~/initia
git fetch
git checkout v0.2.15
make install

sudo systemctl start $BINARY.service
