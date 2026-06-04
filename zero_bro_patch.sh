#!/bin/bash
set -e

cd ~/HighCoin

echo "[ZERO BRO] Fixing all broken paths..."

# Corregge link errati in index.md
sed -i 's|HighCoin/quantum-gateway.html|quantum-gateway.html|g' docs/index.md
sed -i 's|HighCoin/faucet.html|faucet.html|g' docs/index.md
sed -i 's|HighCoin/zlang-playground.html|zlang-playground.html|g' docs/index.md
sed -i 's|HighCoin/zlang-miner.html|zlang-miner.html|g' docs/index.md

# Corregge link errati in tutte le pagine HTML/MD
sed -i 's|HighCoin/||g' docs/*.html 2>/dev/null || true
sed -i 's|HighCoin/||g' docs/*.md 2>/dev/null || true

# Forza rebuild GitHub Pages
touch docs/.rebuild_$(date +%s)

git add -A
git commit -m "ZERO BRO PATCH: fixed all links + forced rebuild"
git push

echo "[ZERO BRO] Completed"
