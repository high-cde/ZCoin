#!/bin/bash

RPC="http://127.0.0.1:8332"
USER="highcoin"
PASS="password"

LOG="faucet_claims.log"
AMOUNT=1

IP=$(echo $REMOTE_ADDR)
UA=$(echo $HTTP_USER_AGENT)
NOW=$(date +%s)

WALLET=$(echo "$QUERY_STRING" | sed -n 's/^.*wallet=\([^&]*\).*$/\1/p')

if [ -z "$WALLET" ]; then
    WALLET=$(curl -s --user $USER:$PASS -X POST -d '{"method":"getnewaddress"}' $RPC | jq -r '.result')
fi

LAST_IP=$(grep "IP:$IP " $LOG 2>/dev/null | tail -n 1 | awk '{print $2}' | sed 's/TIME://')
if [ ! -z "$LAST_IP" ]; then
    DIFF=$((NOW - LAST_IP))
    if [ $DIFF -lt 3600 ]; then
        echo "WAIT_IP"
        exit 0
    fi
fi

LAST_WALLET=$(grep "WALLET:$WALLET " $LOG 2>/dev/null | tail -n 1 | awk '{print $3}' | sed 's/WALLET://')
if [ ! -z "$LAST_WALLET" ]; then
    DIFF=$((NOW - LAST_WALLET))
    if [ $DIFF -lt 3600 ]; then
        echo "WAIT_WALLET"
        exit 0
    fi
fi

if echo "$UA" | grep -qi "curl\|python\|wget"; then
    echo "BOT_BLOCKED"
    exit 0
fi

TX=$(curl -s --user $USER:$PASS -X POST -d "{\"method\":\"sendtoaddress\",\"params\":[\"$WALLET\",$AMOUNT]}" $RPC | jq -r '.result')

echo "IP:$IP TIME:$NOW WALLET:$WALLET TX:$TX UA:$UA" >> $LOG

echo "OK $WALLET $TX"
