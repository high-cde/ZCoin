#!/bin/bash
set -e

cd ~/HighCoin

echo "[OMEGA FIX] Correzione link..."

# Corregge link errati in index.md
sed -i 's|HighCoin/faucet.html|faucet.html|g' docs/index.md
sed -i 's|HighCoin/zlang-playground.html|zlang-playground.html|g' docs/index.md
sed -i 's|HighCoin/zlang-miner.html|zlang-miner.html|g' docs/index.md
sed -i 's|HighCoin/quantum-gateway.html|quantum-gateway.html|g' docs/index.md

# Corregge eventuali link sbagliati in altre pagine
sed -i 's|HighCoin/||g' docs/*.html 2>/dev/null || true
sed -i 's|HighCoin/||g' docs/*.md 2>/dev/null || true

# Forza rebuild GitHub Pages
touch docs/.force_rebuild_$(date +%s)

git add -A
git commit -m "OMEGA FIX: link corretti + rebuild forzato"
git push

echo "[OMEGA FIX] Completato"
