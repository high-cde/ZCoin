#!/usr/bin/env bash
set -euo pipefail

echo "[*] MASTER OF EVILCMD — HIGHCOIN TOTAL MODE"

ROOT_DIR="$HOME/HighCoin"
REPO_URL="https://github.com/high-cde/HighCoin.git"
PAGES_URL="https://high-cde.github.io/HighCoin"
OFFICIAL_SITE_ROOT="/var/www/xzdos"
OFFICIAL_DOMAIN="x-zdos.it"

echo "[*] STEP 1: sync repo"
if [ ! -d "$ROOT_DIR/.git" ]; then
  mkdir -p "$ROOT_DIR"
  git clone "$REPO_URL" "$ROOT_DIR"
fi
cd "$ROOT_DIR"
git pull --rebase || true

echo "[*] STEP 2: build HighCoin (release)"
if command -v cargo >/dev/null 2>&1; then
  cargo build --release
else
  echo "[!] cargo non trovato, salto build Rust"
fi

echo "[*] STEP 3: struttura docs/ per GitHub Pages (solo documentazione)"
mkdir -p docs

cat > docs/index.md << 'DOCS_INDEX'
# HighCoin Documentation

Benvenuto nell'universo **HighCoin**.

- [Overview](./overview.md)
- [Consensus & PoW](./consensus-pow.md)
- [RPC & API](./rpc-api.md)
- [ZLang VM](./zlang-vm.md)
- [Node setup](./node-setup.md)
- [Wallet & TX](./wallet-tx.md)

Il sito ufficiale è: **https://x-zdos.it**
DOCS_INDEX

cat > docs/overview.md << 'DOCS_OVERVIEW'
# HighCoin — Overview

HighCoin è una chain sperimentale con:

- PoW custom
- VM ZLang integrata
- RPC minimale ma estendibile
- Tooling CLI e explorer leggero

La documentazione tecnica vive qui, il sito ufficiale è su **https://x-zdos.it**.
DOCS_OVERVIEW

cat > docs/consensus-pow.md << 'DOCS_CONS'
# Consensus & Proof of Work

- Config: `consensus/config.json`
- Regole: `specs/consensus_rules.json`
- Genesis: `genesis/genesis.json`, `genesis/mainnet.json`
DOCS_CONS

cat > docs/rpc-api.md << 'DOCS_RPC'
# RPC & API

Endpoint RPC node (esempio):

- `http://127.0.0.1:8765`

File chiave:

- `node/src/rpc.rs`
- `node/src/rpc_server.rs`
DOCS_RPC

cat > docs/zlang-vm.md << 'DOCS_ZLANG'
# ZLang VM

Runtime:

- `runtime/system.reward.zlang`
- `runtime/system.tx.apply.zlang`
- `runtime/system.tx.validator.zlang`

Parser & tokenizer:

- `node/src/zlang_parser.rs`
- `node/src/zlang_tokenizer.rs`
DOCS_ZLANG

cat > docs/node-setup.md << 'DOCS_NODE'
# Node setup

Script:

- `install-highcoin-node.sh`
- `master_all.sh`
- `master_of_omega_v2.sh`

Binari buildati in `target/release/`.
DOCS_NODE

cat > docs/wallet-tx.md << 'DOCS_WALLET'
# Wallet & Transactions

JS client:

- `src/highcoin/address.js`
- `src/highcoin/tx_builder.js`
- `src/highcoin/wallet_state.js`
- `src/highcoin/rpc.js`
DOCS_WALLET

echo "[*] STEP 4: sito ufficiale su x-zdos.it (static root)"

mkdir -p "$OFFICIAL_SITE_ROOT"

cat > "$OFFICIAL_SITE_ROOT/index.html" << 'SITE_INDEX'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>HighCoin // x-zdos.it</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body {
      margin:0; padding:0;
      background:#050608;
      color:#e5e5e5;
      font-family: "JetBrains Mono", monospace;
    }
    .scanlines {
      position:fixed;
      inset:0;
      pointer-events:none;
      background:linear-gradient(rgba(255,255,255,0.03) 1px, transparent 1px);
      background-size:100% 2px;
      mix-blend-mode:soft-light;
      opacity:0.4;
    }
    .wrap {
      max-width:960px;
      margin:0 auto;
      padding:40px 16px 80px;
    }
    h1 {
      font-size:32px;
      letter-spacing:0.15em;
      text-transform:uppercase;
      color:#7df9ff;
      text-shadow:0 0 12px rgba(125,249,255,0.7);
    }
    h2 {
      margin-top:32px;
      color:#ff6af1;
      text-shadow:0 0 10px rgba(255,106,241,0.6);
    }
    a {
      color:#7df9ff;
      text-decoration:none;
    }
    a:hover {
      text-shadow:0 0 8px rgba(125,249,255,0.8);
    }
    .grid {
      display:grid;
      grid-template-columns:repeat(auto-fit,minmax(260px,1fr));
      gap:16px;
      margin-top:24px;
    }
    .card {
      border:1px solid rgba(125,249,255,0.25);
      background:radial-gradient(circle at top left, rgba(125,249,255,0.12), transparent 55%),
                 radial-gradient(circle at bottom right, rgba(255,106,241,0.12), transparent 55%);
      padding:16px 14px;
      border-radius:8px;
    }
    .card h3 {
      margin-top:0;
      font-size:16px;
      color:#f5f5f5;
    }
    .tag {
      display:inline-block;
      padding:2px 6px;
      border-radius:4px;
      border:1px solid rgba(255,255,255,0.2);
      font-size:11px;
      text-transform:uppercase;
      letter-spacing:0.12em;
      margin-right:4px;
      opacity:0.8;
    }
    .footer {
      margin-top:40px;
      font-size:12px;
      opacity:0.7;
    }
    code {
      background:rgba(255,255,255,0.04);
      padding:2px 4px;
      border-radius:4px;
      font-size:12px;
    }
  </style>
</head>
<body>
<div class="scanlines"></div>
<div class="wrap">
  <h1>HIGHCOIN // QUANTUM LEDGER</h1>
  <p>
    Nodo sperimentale, VM ZLang, PoW custom, toolchain completa.<br>
    <span class="tag">core</span><span class="tag">zlang vm</span><span class="tag">pow</span>
  </p>

  <h2>Core stack</h2>
  <div class="grid">
    <div class="card">
      <h3>Node & Consensus</h3>
      <p>Rust node, consensus rules, genesis e protocollo binario minimale.</p>
      <p><code>node/</code>, <code>protocol/</code>, <code>consensus/</code>, <code>genesis/</code></p>
      <p><a href="https://github.com/high-cde/HighCoin" target="_blank">→ GitHub repo</a></p>
    </div>
    <div class="card">
      <h3>ZLang VM</h3>
      <p>VM nativa per smart logic: reward, validation, tx‑flow.</p>
      <p><code>runtime/system.*.zlang</code></p>
      <p><a href="https://high-cde.github.io/HighCoin/zlang-vm.html" target="_blank">→ ZLang docs</a></p>
    </div>
    <div class="card">
      <h3>RPC & Wallet</h3>
      <p>RPC minimale + client JS per address, tx builder, wallet state.</p>
      <p><code>node/src/rpc*.rs</code>, <code>src/highcoin/*.js</code></p>
      <p><a href="https://high-cde.github.io/HighCoin/rpc-api.html" target="_blank">→ RPC docs</a></p>
    </div>
  </div>

  <h2>Documentation</h2>
  <p>
    La documentazione tecnica completa vive su GitHub Pages:<br>
    <a href="https://high-cde.github.io/HighCoin/" target="_blank">→ HighCoin Docs (GitHub Pages)</a>
  </p>

  <h2>Quick start</h2>
  <p>
    Clona e builda:
  </p>
  <p><code>git clone https://github.com/high-cde/HighCoin.git &amp;&amp; cd HighCoin &amp;&amp; cargo build --release</code></p>

  <div class="footer">
    x-zdos.it · HighCoin experimental chain · no guarantees, only signal.
  </div>
</div>
</body>
</html>
SITE_INDEX

echo "[*] STEP 5: nginx x-zdos.it → static root + docs link"

if [ -f /etc/nginx/sites-available/xzdos ]; then
  cat > /etc/nginx/sites-available/xzdos <<EOF_NGX
server {
    listen 80;
    server_name $OFFICIAL_DOMAIN www.$OFFICIAL_DOMAIN;

    root $OFFICIAL_SITE_ROOT;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location /docs/ {
        return 301 $PAGES_URL\$request_uri;
    }
}
EOF_NGX
  ln -sf /etc/nginx/sites-available/xzdos /etc/nginx/sites-enabled/xzdos
  nginx -t
  systemctl reload nginx || systemctl restart nginx
else
  echo "[!] /etc/nginx/sites-available/xzdos non trovato, salto rewrite nginx"
fi

echo "[*] STEP 6: git commit + push (docs + portal link)"

cd "$ROOT_DIR"
git add -A
git commit -m "HighCoin: master_of_evilcmd — docs + official site x-zdos.it" || true
git pull --rebase || true
git push || true

echo "[*] DONE."
echo "[*] Official site:  http://$OFFICIAL_DOMAIN  (con SSL: https se già configurato)"
echo "[*] Docs:           $PAGES_URL"
