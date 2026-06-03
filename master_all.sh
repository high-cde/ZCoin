#!/bin/bash

cd ~/HighCoin

# Assicura che la cartella docs esista
mkdir -p docs

# Crea o aggiorna la pagina Quantum Gateway
cat > docs/quantum-gateway.md << 'EOF'
# HighCoin Quantum Gateway
Il futuro non arriva. Si compila.

## DSN Gateway — Distributed Sovereign Network
Il DSN Gateway è il punto di accesso al nuovo ecosistema HighCoin.

Collega:
- HighCoin Mainnet
- Z-Lang Runtime
- BlockZLang PoW Engine
- ZDOS Core
- Token Factory Layer

Ogni richiesta che attraversa il DSN Gateway viene:
1. Validata
2. Compilata
3. Eseguita
4. Firmata
5. Propagata nella rete

## HighCoin — La moneta che esegue codice
HighCoin non è solo un asset.
È un motore di esecuzione distribuito.

Ogni blocco contiene:
- transazioni
- logica
- micro-programmi BlockZLang
- seed di consenso
- firma del nodo

## Token Factory (ispirata a POA Network 2017)
"Un token può essere generato da un contratto, non da una autorità."

### Esempio di Token in Z-Lang
token MyToken {
    name: "Quantum Sparks"
    symbol: "QSPK"
    supply: 1000000
    decimals: 8
}

## Attesa palpabile
Il Quantum Gateway sta:
- generando seed BlockZLang
- preparando la Token Factory
- sincronizzando i nodi DSN
- calibrando la difficoltà PoW
EOF

# Crea index se non esiste
if [ ! -f docs/index.md ]; then
    echo "# HighCoin Documentation" > docs/index.md
fi

# Aggiunge link se non presente
grep -q "quantum-gateway" docs/index.md || echo "- [HighCoin Quantum Gateway](quantum-gateway.md)" >> docs/index.md

# Commit + push
git add docs/quantum-gateway.md docs/index.md
git commit -m "MASTER ALL: Quantum Gateway + DSN + ZLang"
git push
