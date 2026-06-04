#!/usr/bin/env bash
set -e

echo "[Ω] GENESIS v2 — autobuild/autofix/autoclean/autosync"

ROOT=~/HighCoin

echo "[Ω] Scrivo runtime.rs"
cat > "$ROOT/node/src/runtime.rs" <<'EOR'
<QUI METTO IL FILE COMPLETO RUNTIME.RS SENZA VARIABILI BASH>
EOR

echo "[Ω] Scrivo evm_rpc.rs"
cat > "$ROOT/node/src/rpc/evm_rpc.rs" <<'EOR'
<QUI METTO IL FILE COMPLETO EVM_RPC.RS>
EOR

echo "[Ω] Scrivo router.rs"
cat > "$ROOT/node/src/rpc/router.rs" <<'EOR'
<QUI METTO IL FILE COMPLETO ROUTER.RS>
EOR

echo "[Ω] Scrivo server.rs"
cat > "$ROOT/node/src/server.rs" <<'EOR'
<QUI METTO IL FILE COMPLETO SERVER.RS>
EOR

echo "[Ω] Scrivo main.rs"
cat > "$ROOT/node/src/main.rs" <<'EOR'
<QUI METTO IL FILE COMPLETO MAIN.RS>
EOR

echo "[Ω] cargo build --release"
cd "$ROOT"
cargo add chrono --quiet || true
cargo build --release

echo "[Ω] kill old node"
pkill node || true

echo "[Ω] start node"
nohup ./target/release/node > /var/log/highcoin.log 2>&1 &
sleep 1

echo "[Ω] Test chainId"
curl -s -X POST https://rpc.x-zdos.it \
-H "Content-Type: application/json" \
--data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}'

echo
echo "[Ω] GENESIS v2 COMPLETATA."
