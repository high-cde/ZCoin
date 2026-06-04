#!/bin/bash
set -e

cd ~/HighCoin

echo "[OMEGA PATCH] Fixing broken links..."

# Corregge link errati in tutte le pagine
sed -i 's|HighCoin/quantum-gateway.html|quantum-gateway.html|g' docs/index.md
sed -i 's|HighCoin/faucet.html|faucet.html|g' docs/index.md
sed -i 's|HighCoin/zlang-playground.html|zlang-playground.html|g' docs/index.md
sed -i 's|HighCoin/zlang-miner.html|zlang-miner.html|g' docs/index.md

# Forza rebuild GitHub Pages
touch docs/.force_rebuild_$(date +%s)

git add -A
git commit -m "OMEGA PATCH: fixed broken links + forced rebuild"
git push

echo "[OMEGA PATCH] Completed"
