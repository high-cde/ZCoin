#!/bin/bash
set -e

cd ~/HighCoin

echo "[OMEGA V2] Start"

mkdir -p docs

############################################
# 1. HOMEPAGE ZDOS + RIFERIMENTI + PLAYGROUND + MINER
############################################

cat > docs/index.md << 'EOF'
<script>
if (window.location.href.includes("utm_source")) {
    window.location.href = "https://high-cde.github.io/HighCoin/";
}
</script>

<link rel="stylesheet" href="zdos.css">

<div class="container">

# HighCoin — Quantum Portal (ZDOS Edition)

Benvenuto nel portale ufficiale di HighCoin.

---

## Riferimenti ufficiali

- Repository principale:
  https://github.com/high-cde/HighCoin

- Profilo sviluppatore:
  https://github.com/high-cde

- Server Discord (HighCoin / ZDOS / DSN):
  https://discord.gg/djuycwjRKB

---

## Moduli

- [Quantum Gateway](quantum-gateway.html)
- [HighCoin Faucet](faucet.html)
- [Z-Lang Playground](zlang-playground.html)
- [Z-Lang Miner](zlang-miner.html)

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

echo "[OMEGA V2] Homepage OK"

############################################
# 2. QUANTUM GATEWAY
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
- Token Factory Layer

---

## Stato

- Seed BlockZLang: attivo
- Sincronizzazione nodi: attiva
- Token Factory: in preparazione

---

## Flusso

1. Richiesta in ingresso
2. Validazione
3. Compilazione Z-Lang
4. Esecuzione in HighVM
5. Firma
6. Propagazione nella rete

</div>
EOF

echo "[OMEGA V2] Gateway OK"

############################################
# 3. Z-LANG PLAYGROUND — DSN RESONANCE
############################################

cat > docs/zlang-playground.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
<title>Z-Lang Playground — HighCoin</title>
<link rel="stylesheet" href="zdos.css">
<style>
textarea { width: 100%; height: 260px; background:#000; color:#0f0; border:1px solid #0f0; font-family:Consolas,monospace; }
pre { background:#000; color:#0f0; border:1px solid #0f0; padding:10px; }
</style>
</head>
<body>

<div class="container">
<h1>Z-Lang Playground — DSN Resonance</h1>

<div class="box">
<p>Modulo concettuale Z-Lang collegato al token DSN (0xfc90516a1f736FaC557e09D8853dB80dA192c296).</p>
<p>Genera "microtoken" temporanei in risposta alle variazioni di saldo DSN.</p>
</div>

<div class="box">
<h2>Codice Z-Lang</h2>
<textarea id="code">
module DSN_Resonance {

    token DSN {
        address: "0xfc90516a1f736FaC557e09D8853dB80dA192c296"
    }

    state last_balance: uint64 = 0

    on_block() {

        let current = DSN.balance_of(caller)

        if current != last_balance {

            let delta = current - last_balance

            spawn microtoken {
                supply: delta
                ttl: 1
            }

            log("DSN Resonance Pulse: ", delta)

            last_balance = current
        }
    }
}
</textarea>
</div>

<div class="box">
<h2>Simulazione concettuale</h2>
<button onclick="simulate()">Simula variazione saldo</button>
<pre id="output"></pre>
</div>

</div>

<script>
function simulate() {
    const out = document.getElementById("output");
    out.textContent =
        "Simulazione DSN Resonance:\\n" +
        "- Blocco N: saldo DSN = 1000\\n" +
        "- Blocco N+1: saldo DSN = 1300\\n" +
        "- Delta = 300\\n" +
        "- microtoken.spawn(supply=300, ttl=1)\\n" +
        "- log: DSN Resonance Pulse: 300\\n\\n" +
        "Nella HighVM reale, il modulo reagirebbe ad ogni blocco alle variazioni di saldo DSN.";
}
</script>

</body>
</html>
EOF

echo "[OMEGA V2] Playground OK"

############################################
# 4. Z-LANG MINER — WEB VERSION PER POSSESSORI DI HIGHCOIN
############################################

cat > docs/zlang-miner.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
<title>Z-Lang Miner — HighCoin</title>
<link rel="stylesheet" href="zdos.css">
<style>
textarea { width: 100%; height: 220px; background:#000; color:#0f0; border:1px solid #0f0; font-family:Consolas,monospace; }
pre { background:#000; color:#0f0; border:1px solid #0f0; padding:10px; }
input { background:#000; color:#0f0; border:1px solid #0f0; padding:5px; width:100%; }
</style>
</head>
<body>

<div class="container">
<h1>Z-Lang Miner — HighCoin Holders</h1>

<div class="box">
<p>Questo "miner" concettuale in Z-Lang è pensato per i possessori di HighCoin.</p>
<p>Invece di cercare solo hash, esegue micro-programmi Z-Lang che generano token in base al contributo logico.</p>
</div>

<div class="box">
<h2>Parametri di mining</h2>
<label>Indirizzo HighCoin (simulato):</label>
<input id="addr" placeholder="HICxxxxxxxxxxxxxxxxxxxx">
<br><br>
<button onclick="mine()">Esegui ciclo di mining</button>
</div>

<div class="box">
<h2>Codice Z-Lang (Miner Concept)</h2>
<textarea readonly>
module HighCoin_Miner {

    token HIC {
        symbol: "HIC"
    }

    state difficulty: uint64 = 1000

    function mine(contrib: uint64) {

        if contrib > difficulty {

            let reward = contrib - difficulty

            mint HIC to caller amount reward

            log("HighCoin Logic-Mining Reward: ", reward)
        }
    }
}
</textarea>
</div>

<div class="box">
<h2>Output simulato</h2>
<pre id="miner_out"></pre>
</div>

</div>

<script>
function mine() {
    const addr = document.getElementById("addr").value || "HIC-DEMO-ADDRESS";
    const contrib = Math.floor(Math.random() * 5000) + 500;
    const diff = 1000;
    let out = "";

    out += "Indirizzo: " + addr + "\\n";
    out += "Contributo logico simulato: " + contrib + "\\n";
    out += "Difficolta: " + diff + "\\n";

    if (contrib > diff) {
        const reward = contrib - diff;
        out += "Reward HIC: " + reward + "\\n";
        out += "Log: HighCoin Logic-Mining Reward: " + reward + "\\n";
    } else {
        out += "Nessuna reward: contributo insufficiente.\\n";
    }

    document.getElementById("miner_out").textContent = out;
}
</script>

</body>
</html>
EOF

echo "[OMEGA V2] Z-Lang Miner OK"

############################################
# 5. COMMIT + PUSH
############################################

git add -A
git commit -m "OMEGA V2: Rebuild portal + Z-Lang Playground + Z-Lang Miner"
git push

echo "[OMEGA V2] Completed"
