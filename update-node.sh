#!/bin/bash

folder=$(echo $(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) | awk -F/ '{print $NF}')
source ~/scripts/$folder/cfg

sudo systemctl stop $BINARY.service

cd ~
git clone https://github.com/initia-labs/initia.git
cd initia
git checkout v0.2.15
make install
