#!/bin/bash

#usage: bash vote.sh <key> <prpoposition> <option>

folder=$(echo $(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) | awk -F/ '{print $NF}')
source ~/scripts/$folder/cfg

[ -z $1 ] && read -p "From ($KEY) ? " key || key=$1
[ -z $key ] && key=$KEY

[ -z $2 ] && read -p "Proposition ? " prop || prop=$2
[ -z $3 ] && read -p "Option ? " option || option=$3

echo $PASS | $BINARY tx gov vote $prop $option --from $key \
 --gas-prices $GAS_PRICE --gas-adjustment $GAS_ADJ --gas auto -y
