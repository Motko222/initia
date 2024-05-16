#!/bin/bash

folder=$(echo $(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) | awk -F/ '{print $NF}')
config=~/scripts/$folder/cfg

#install binary
cd ~
git clone https://github.com/initia-labs/initia.git
cd initia
git checkout v0.2.14
make install

$BINARY version
