#!/bin/bash

folder=$(echo $(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) | awk -F/ '{print $NF}')
source ~/scripts/$folder/cfg
source ~/.bash_profile

network=testnet
group=validator
id=$ID

json=$(curl -s $RPC_HOST:$RPC_PORT/status | jq .result.sync_info)
pid=$(pgrep $BINARY)
version=$($BINARY version)
chain=$(initiad status | jq -r .node_info.network)
foldersize1=$(du -hs $DATA | awk '{print $1}')
latestBlock=$(echo $json | jq -r .latest_block_height)
network_height=$(curl -s https://rpc-initia-testnet.trusted-point.com/status | jq -r .result.sync_info.latest_block_height)
catchingUp=$(echo $json | jq -r .catching_up)
votingPower=$($BINARY status 2>&1 | jq -r .ValidatorInfo.VotingPower)
wallet=$(echo $PASS | $BINARY keys show $KEY -a)
valoper=$(echo $PASS | $BINARY keys show $KEY -a --bech val)
moniker=$($BINARY query mstaking validator $valoper -o json | jq -r .description.moniker)
[ -z $moniker ] && moniker="NA"
pubkey=$($BINARY tendermint show-validator --log_format json | jq -r .key)
delegators=$($BINARY query mstaking delegations-to $valoper -o json | jq '.delegation_responses | length')
jailed=$($BINARY query mstaking validator $valoper -o json | jq -r .jailed)
if [ -z $jailed ]; then jailed=false; fi
tokens=$($BINARY query mstaking validator $valoper -o json | jq -r '.tokens[] | select(.denom=="uinit")' | jq -r .amount | awk '{print $1/1000000}' )
balance=$($BINARY query bank balances $wallet -o json 2>/dev/null \
      | jq -r '.balances[] | select(.denom=="uinit")' | jq -r .amount | awk '{print $1/1000000}')
active=$(initiad query consensus comet validator-set | grep -c $pubkey)
threshold=$(initiad query consensus comet validator-set -o json | jq -r .validators[].voting_power | tail -1)

if $catchingUp
 then 
  status="syncing"
  message="height $latestBlock/$network_height left $(( network_height - latestBlock ))"
 else 
  if [ $active -eq 1 ]; then status=active; else status=inactive;message="height $latestBlock/$network_height left $(( network_height - latestBlock ))"; fi
fi

if $jailed
 then
  status="jailed"
  message="jailed"
fi 

if [ -z $pid ];
then status="offline";
 message="process not running";
fi

#json output
cat << EOF
{
  "updated":"$(date --utc +%FT%TZ)",
  "id":"$id",
  "machine":"$MACHINE",
  "version":"$version",
  "chain":"$chain",
  "status":"$status",
  "message":"$message",
  "rpcport":"$RPC_PORT",
  "folder1":"$foldersize1",
  "moniker":"$moniker",
  "key":"$KEY",
  "wallet":"$wallet",
  "valoper":"$valoper",
  "pubkey":"$pubkey",
  "catchingUp":"$catchingUp",
  "jailed":"$jailed",
  "active":$active,
  "height":$latestBlock,
  "network_height":$network_height,
  "votingPower":$votingPower,
  "tokens":$tokens,
  "threshold":$threshold,
  "delegators":$delegators,
  "balance":$balance
}
EOF

# send data to influxdb
if [ ! -z $INFLUX_HOST ]
then
 curl --request POST \
 "$INFLUX_HOST/api/v2/write?org=$INFLUX_ORG&bucket=$INFLUX_BUCKET&precision=ns" \
  --header "Authorization: Token $INFLUX_TOKEN" \
  --header "Content-Type: text/plain; charset=utf-8" \
  --header "Accept: application/json" \
  --data-binary "
    report,machine=$MACHINE,id=$id,moniker=$moniker,grp=$group status=\"$status\",message=\"$message\",version=\"$version\",url=\"$url\",chain=\"$chain\",tokens=\"$tokens\",threshold=\"$threshold\",active=\"$active\",jailed=\"$jailed\" $(date +%s%N) 
    "
fi
