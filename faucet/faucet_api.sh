#!/bin/bash

RPC="http://127.0.0.1:8332"
USER="highcoin"
PASS="password"

LOG="faucet_claims.log"
AMOUNT=1

IP=$(echo $REMOTE_ADDR)

# anti-abuso: 1 claim ogni 60 minuti
if grep -q "$IP" $LOG; then
    LAST=$(grep "$IP" $LOG | tail -n 1 | awk '{print $2}')
    NOW=$(date +%s)
    DIFF=$((NOW - LAST))
    if [ $DIFF -lt 3600 ]; then
        echo "WAIT"
        exit 0
    fi
fi

# genera indirizzo
ADDR=$(curl -s --user $USER:$PASS -X POST -d '{"method":"getnewaddress"}' $RPC | jq -r '.result')

# invia 1 HIC
TX=$(curl -s --user $USER:$PASS -X POST -d "{\"method\":\"sendtoaddress\",\"params\":[\"$ADDR\",$AMOUNT]}" $RPC | jq -r '.result')

# log
echo "$IP $(date +%s) $ADDR $TX" >> $LOG

echo "$ADDR $TX"
