#!/bin/bash
set -e

cd ~/HighCoin

echo "[MASTER OF DIRT] Start"

mkdir -p faucet
mkdir -p docs

############################################
# 1. FAUCET API BACKEND (ANTI-ABUSO V2)
############################################

cat > faucet/faucet_api.sh << 'EOF'
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
EOF

chmod +x faucet/faucet_api.sh

echo "[MASTER OF DIRT] Backend OK"

############################################
# 2. FRONTEND HTML (STILE FREE LITECOIN)
############################################

cat > docs/faucet.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
<title>HighCoin Faucet</title>
<style>
body { font-family: Arial; background: #111; color: #0f0; text-align: center; }
.box { margin: 50px auto; padding: 20px; width: 400px; background: #000; border: 1px solid #0f0; }
button { padding: 10px 20px; background: #0f0; border: none; cursor: pointer; }
</style>
</head>
<body>

<h1>HighCoin Faucet</h1>
<div class="box">
<p>Ottieni 1 HIC gratis ogni 60 minuti.</p>
<button onclick="claim()">CLAIM NOW</button>
<p id="result"></p>
</div>

<script>
function claim() {
    fetch("https://YOUR_VPS_IP/faucet/faucet_api.sh")
    .then(r => r.text())
    .then(t => document.getElementById("result").innerHTML = t);
}
</script>

</body>
</html>
EOF

echo "[MASTER OF DIRT] Frontend OK"

############################################
# 3. AGGIUNGI LINK AL PORTALE
############################################

grep -q "faucet.html" docs/index.md || echo "- [HighCoin Faucet](faucet.html)" >> docs/index.md

############################################
# 4. COMMIT + PUSH
############################################

git add -A
git commit -m "MASTER OF DIRT: Faucet backend + frontend + anti-abuso"
git push

echo "[MASTER OF DIRT] Completed"
