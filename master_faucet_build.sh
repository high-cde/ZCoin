#!/bin/bash
set -e

cd ~/HighCoin

mkdir -p faucet
mkdir -p docs

############################################
# 1. FAUCET API (backend)
############################################

cat > faucet/faucet_api.sh << 'EOF'
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
EOF

chmod +x faucet/faucet_api.sh

############################################
# 2. FRONTEND HTML (stile FreeLitecoin)
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

############################################
# 3. AGGIUNGI LINK AL SITO
############################################

grep -q "faucet" docs/index.md || echo "- [HighCoin Faucet](faucet.html)" >> docs/index.md

############################################
# 4. COMMIT + PUSH
############################################

git add -A
git commit -m "AUTOFAUCET BUILD: Faucet API + Faucet HTML"
git push
