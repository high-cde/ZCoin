#!/bin/bash
set -e

echo "[ABSOLUTE REBUILD] START"

############################################
# 1. ELIMINA COMPLETAMENTE LA CARTELLA DOCS
############################################

rm -rf docs
mkdir docs

############################################
# 2. ELIMINA TUTTI I FILE NASCOSTI
############################################

find . -name ".DS_Store" -delete
find . -name "._*" -delete
find . -name ".force_*" -delete
find . -name ".rebuild_*" -delete

############################################
# 3. RICREA INDEX
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
# 4. RICREA GATEWAY
############################################

cat > docs/quantum-gateway.html << 'EOF'
<link rel="stylesheet" href="zdos.css">

<div class="container">

<h1>Quantum Gateway</h1>

<p>Modulo centrale del sistema HighCoin.</p>

</div>
EOF

############################################
# 5. RICREA PLAYGROUND
############################################

cat > docs/zlang-playground.html << 'EOF'
<link rel="stylesheet" href="zdos.css">

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
EOF

############################################
# 6. RICREA MINER
############################################

cat > docs/zlang-miner.html << 'EOF'
<link rel="stylesheet" href="zdos.css">

<div class="container">
<h1>Z-Lang Miner</h1>

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
EOF

############################################
# 7. FORZA REBUILD GITHUB PAGES
############################################

touch docs/.absolute_rebuild_$(date +%s)

############################################
# 8. COMMIT + PUSH
############################################

git add -A
git commit -m "ABSOLUTE REBUILD: full regeneration of HighCoin portal"
git push

echo "[ABSOLUTE REBUILD] COMPLETED"
