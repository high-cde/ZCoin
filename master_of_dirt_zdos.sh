#!/bin/bash
set -e

cd ~/HighCoin

echo "[ZDOS THEME] Start"

mkdir -p docs

############################################
# 1. THEME CSS ZDOS
############################################

cat > docs/zdos.css << 'EOF'
body {
    background-color: #000000;
    color: #00ff00;
    font-family: Consolas, monospace;
    margin: 0;
    padding: 0;
}

h1, h2, h3 {
    color: #00ff00;
    border-bottom: 1px solid #00ff00;
    padding-bottom: 5px;
}

a {
    color: #00ff00;
    text-decoration: none;
}

a:hover {
    text-shadow: 0 0 5px #00ff00;
}

.container {
    width: 80%;
    margin: auto;
    padding: 20px;
    border: 1px solid #00ff00;
    background: #000000;
}

.box {
    border: 1px solid #00ff00;
    padding: 15px;
    margin-top: 20px;
    background: #000000;
}

button {
    background: #00ff00;
    color: #000000;
    border: none;
    padding: 10px 20px;
    cursor: pointer;
}

button:hover {
    background: #00cc00;
}
EOF

echo "[ZDOS THEME] CSS OK"

############################################
# 2. HOMEPAGE ZDOS
############################################

cat > docs/index.md << 'EOF'
<link rel="stylesheet" href="zdos.css">

<div class="container">

# HighCoin — Quantum Portal (ZDOS Edition)

Benvenuto nel portale ufficiale di HighCoin.

---

## Documentazione

- [Quantum Gateway](quantum-gateway.md)
- [HighCoin Faucet](faucet.html)

---

## Stato della rete

- DSN Gateway: attivo
- Z-Lang Compiler: attivo
- BlockZLang PoW Engine: attivo
- HighVM Runtime: attivo

---

## Visione

HighCoin è un motore di esecuzione distribuito basato su Z-Lang e BlockZLang.

</div>
EOF

echo "[ZDOS THEME] Homepage OK"

############################################
# 3. FAUCET ZDOS
############################################

cat > docs/faucet.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
<title>HighCoin Faucet</title>
<link rel="stylesheet" href="zdos.css">
</head>
<body>

<div class="container">
<h1>HighCoin Faucet</h1>

<div class="box">
<p>Ottieni 1 HIC gratis ogni 60 minuti.</p>
<button onclick="claim()">CLAIM NOW</button>
<p id="result"></p>
</div>

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

echo "[ZDOS THEME] Faucet OK"

############################################
# 4. QUANTUM GATEWAY ZDOS
############################################

cat > docs/quantum-gateway.md << 'EOF'
<link rel="stylesheet" href="zdos.css">

<div class="container">

# HighCoin Quantum Gateway (ZDOS Edition)

Il DSN Gateway collega:
- HighCoin Mainnet
- Z-Lang Runtime
- BlockZLang PoW Engine
- ZDOS Core

---

## Stato

- Seed BlockZLang: attivo
- Sincronizzazione nodi: attiva
- Token Factory: in preparazione

</div>
EOF

echo "[ZDOS THEME] Gateway OK"

############################################
# 5. COMMIT + PUSH
############################################

git add -A
git commit -m "ZDOS THEME: full site restyle"
git push

echo "[ZDOS THEME] Completed"
