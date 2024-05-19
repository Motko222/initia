#!/bin/bash

folder=$(echo $(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) | awk -F/ '{print $NF}')
config=~/scripts/$folder/cfg

# Update and install dependencies
sudo apt update && sudo apt install -y curl git jq build-essential gcc unzip wget lz4

ufw disable
# Install Golang
wget https://go.dev/dl/go1.22.3.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.22.3.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
go version

#install binary
cd ~
git clone https://github.com/initia-labs/initia.git
cd initia
git checkout v0.2.15
make install

cd ~/scripts/initia
cp cfg.sample cfg

$BINARY version
