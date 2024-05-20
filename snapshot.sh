#!/bin/bash

source ~/.bash_profile

read -p "Are you sure? " answer
case $answer in
  y|Y|yes|YES) echo "Restoring from snapshot..." ;;
  *) exit 1 ;;
esac

#stop service
sudo systemctl stop initiad.service

# Backup the priv_validator_state
cp $HOME/.initia/data/priv_validator_state.json $HOME/.initia/priv_validator_state.json.backup

# Reset the node
rm -rf $HOME/.initia/data
rm -rf $HOME/.initia/wasm
initiad comet unsafe-reset-all --home $HOME/.initia --keep-addr-book

# Configure pruning and indexer
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.initia/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.initia/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"0\"/" $HOME/.initia/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"10\"/" $HOME/.initia/config/app.toml
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.initia/config/config.toml

# Disable state sync
sed -i -e "s/^enable *=.*/enable = false/" $HOME/.initia/config/config.toml

read -p "Snapshot height? (https://polkachu.com/testnets/initia/snapshots) :" height

curl https://snapshots.polkachu.com/testnet-snapshots/initia/initia_$height.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.initia

# Restore the priv_validator_state
mv $HOME/.initia/priv_validator_state.json.backup $HOME/.initia/data/priv_validator_state.json

echo "Snapshot restore finished, start the node."
