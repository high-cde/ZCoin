#!/bin/bash
set -e

echo "[ZERO BRO REBUILD] START"

############################################
# 1. RESET CARTELLA DEL SITO
############################################

rm -rf docs
mkdir -p docs

############################################
# 2. RICREA HOMEPAGE
############################################

cat > docs/index.md << 'EOF'
<link rel="stylesheet" href="zdos.css">

<div class="container">

# HighCoin — Quantum Portal (ZDOS Edition)

Benvenuto nel portale ufficiale di HighCoin.

---

## Riferimenti ufficiali

- Repository principale: https://github.com/high-cde/HighCoin
- Profilo sviluppatore: https://github.com/high-cde
- Server Discord: https://discord.gg/djuycwjRKB

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

############################################
# 3. RICREA QUANTUM GATEWAY
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

############################################
# 4. RICREA PLAYGROUND
############################################

cat > docs/zlang-playground.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
<title>Z-Lang Playground</title>
<link rel="stylesheet" href="zdos.css">
</head>
<body>

<div class="container">
<h1>Z-Lang Playground</h1>

<textarea style="width:100%;height:260px;background:#000;color:#0f0;border:1px solid #0f0;">
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

</body>
</html>
EOF

############################################
# 5. RICREA MINER
############################################

cat > docs/zlang-miner.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
<title>Z-Lang Miner</title>
<link rel="stylesheet" href="zdos.css">
</head>
<body>

<div class="container">
<h1>Z-Lang Miner</h1>

<p>Simulatore di mining logico per HighCoin.</p>

<pre style="background:#000;color:#0f0;border:1px solid #0f0;padding:10px;">
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
</pre>

</div>

</body>
</html>
EOF

############################################
# 6. FORZA REBUILD GITHUB PAGES
############################################

touch docs/.force_rebuild_$(date +%s)

############################################
# 7. COMMIT + PUSH
############################################

git add -A
git commit -m "ZERO BRO REBUILD: full site regeneration"
git push

echo "[ZERO BRO REBUILD] COMPLETED"
